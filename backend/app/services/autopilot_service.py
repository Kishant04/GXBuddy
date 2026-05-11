from __future__ import annotations

import uuid
from datetime import datetime, timedelta
from typing import Optional

from app.core.database import get_supabase_client

UNDO_WINDOW_SECONDS = 60

# In-memory undo store  { split_id: { user_id, lines, expires_at } }
_pending_undos: dict = {}


def _get_pockets(user_id: str) -> list[dict]:
    db = get_supabase_client()
    res = db.table("Pocket").select("*").eq("userid", user_id).execute()
    return res.data or []


def detect_salary(user_id: str, amount: float) -> bool:
    """Returns True if transaction qualifies as a salary credit."""
    db = get_supabase_client()
    try:
        res = (
            db.table("User")
            .select("salarythreshold")
            .eq("id", user_id)
            .limit(1)
            .execute()
        )
        if res.data:
            threshold = float(res.data[0].get("salarythreshold", 800))
            return amount >= threshold
    except Exception:
        pass
    return amount >= 800  # safe default


from app.ai.mascot_engine import MascotInput, determine_mascot_state
from app.schemas.contracts import MascotStatus

def execute_split(user_id: str, salary_amount: float) -> dict:
    """
    1. Load pockets with split rules
    2. Calculate each pocket's allocation
    3. Update pocket balances in Supabase
    4. Store undo snapshot
    5. Return split summary for animation
    """
    pockets = _get_pockets(user_id)
    if not pockets:
        return {"error": "No pockets configured. Set up pockets first."}

    db = get_supabase_client()
    lines = []
    total_routed = 0.0

    for pocket in pockets:
        rule = pocket.get("splitrule") or {}
        r_type = rule.get("type", "percent")
        r_val = float(rule.get("value", 0))

        if r_val <= 0:
            continue

        amount = (
            round(salary_amount * r_val / 100, 2)
            if r_type == "percent"
            else round(r_val, 2)
        )

        current = float(pocket.get("balance", 0))
        target = float(pocket.get("target", 0))
        headroom = max(0, target - current)
        amount = min(amount, headroom)

        if amount <= 0:
            continue

        new_balance = current + amount
        db.table("Pocket").update({"balance": new_balance}).eq("id", pocket["id"]).execute()

        lines.append(
            {
                "pocket_id": pocket["id"],
                "pocket_name": pocket["name"],
                "amount": amount,
                "rule_type": r_type,
                "rule_value": r_val,
            }
        )
        total_routed += amount

    split_id = str(uuid.uuid4())
    expires_at = datetime.utcnow() + timedelta(seconds=UNDO_WINDOW_SECONDS)

    _pending_undos[split_id] = {
        "user_id": user_id,
        "lines": lines,
        "expires_at": expires_at,
    }

    mascot = determine_mascot_state(
        MascotInput(
            weekly_percentage_used=0.0,  # context specific
            savings_streak_days=0,
            upcoming_bill_due_soon=False,
            weekly_alert_count=0,
            risk_score=0.0,
            is_savings_context=True,
        )
    )

    return {
        "split_id": split_id,
        "total_routed": round(total_routed, 2),
        "lines": lines,
        "undo_deadline": expires_at.isoformat(),
        "mascot": mascot.model_dump(mode="json"),
    }


def undo_split(user_id: str, split_id: str) -> dict:
    snapshot = _pending_undos.get(split_id)

    if not snapshot:
        return {"reversed": False, "message": "Split not found or already undone."}

    if snapshot["user_id"] != user_id:
        return {"reversed": False, "message": "Unauthorised."}

    if datetime.utcnow() > snapshot["expires_at"]:
        _pending_undos.pop(split_id, None)
        return {"reversed": False, "message": "Undo window has expired (60 seconds)."}

    db = get_supabase_client()
    for line in snapshot["lines"]:
        pocket_res = (
            db.table("Pocket")
            .select("balance")
            .eq("id", line["pocket_id"])
            .limit(1)
            .execute()
        )
        if pocket_res.data:
            current = float(pocket_res.data[0]["balance"])
            restored = max(0.0, current - line["amount"])
            db.table("Pocket").update({"balance": restored}).eq("id", line["pocket_id"]).execute()

    _pending_undos.pop(split_id, None)
    return {"reversed": True, "message": "Split reversed. Your balance has been restored."}


def get_undo_context(user_id: str) -> Optional[str]:
    pockets = _get_pockets(user_id)
    if not pockets:
        return None

    most_needed = max(
        pockets,
        key=lambda p: float(p.get("target", 0)) - float(p.get("balance", 0)),
    )
    gap = round(float(most_needed.get("target", 0)) - float(most_needed.get("balance", 0)), 2)

    if gap <= 0:
        return "All your pockets are fully funded! Sure you want to undo?"
    return f"Are you sure? Your {most_needed['name']} still needs RM{gap:.2f} more."

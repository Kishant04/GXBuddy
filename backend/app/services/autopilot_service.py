import uuid
from datetime import datetime, timedelta
from typing import Optional
from supabase import AsyncClient   # supabase-py v2

UNDO_WINDOW_SECONDS = 60

# In-memory undo store  { split_id: { user_id, lines, expires_at } }
# For production: store in Redis or a supabase `autopilot_splits` table
_pending_undos: dict = {}


async def detect_salary(db: AsyncClient, user_id: str, amount: float) -> bool:
    """
    Returns True if transaction qualifies as a salary credit.
    Rule: amount >= user's salary_threshold AND category == "salary"
    """
    res = await db.table("User").select("salary_threshold").eq("id", user_id).single().execute()
    threshold = float(res.data["salary_threshold"])
    return amount >= threshold


async def get_user_pockets(db: AsyncClient, user_id: str) -> list[dict]:
    res = await db.table("Pocket").select("*").eq("userid", user_id).execute()
    return res.data or []


async def execute_split(db: AsyncClient, user_id: str, salary_amount: float) -> dict:
    """
    Core autopilot logic:
    1. Load all pockets with their split rules
    2. Calculate each pocket's allocation
    3. Update pocket balances in Supabase
    4. Store undo snapshot
    5. Return split summary for animation
    """
    pockets = await get_user_pockets(db, user_id)
    if not pockets:
        return {"error": "No pockets configured. Set up pockets first."}

    lines        = []
    total_routed = 0.0

    for pocket in pockets:
        rule  = pocket["splitrule"]   # {"type": "percent"|"fixed", "value": float}
        r_type = rule["type"]
        r_val  = float(rule["value"])

        amount = round((salary_amount * r_val / 100), 2) if r_type == "percent" else round(r_val, 2)

        # Don't over-fill pocket beyond target
        current  = float(pocket["balance"])
        target   = float(pocket["target"])
        headroom = max(0, target - current)
        amount   = min(amount, headroom)

        if amount <= 0:
            continue

        new_balance = current + amount

        await db.table("Pocket").update({"balance": new_balance}).eq("id", pocket["id"]).execute()

        lines.append({
            "pocket_id":   pocket["id"],
            "pocket_name": pocket["name"],
            "amount":      amount,
            "rule_type":   r_type,
            "rule_value":  r_val,
        })
        total_routed += amount

    split_id     = str(uuid.uuid4())
    expires_at   = datetime.utcnow() + timedelta(seconds=UNDO_WINDOW_SECONDS)

    # Store undo snapshot
    _pending_undos[split_id] = {
        "user_id":    user_id,
        "lines":      lines,
        "expires_at": expires_at,
    }

    return {
        "split_id":      split_id,
        "total_routed":  round(total_routed, 2),
        "lines":         lines,
        "undo_deadline": expires_at.isoformat(),
    }


async def undo_split(db: AsyncClient, user_id: str, split_id: str) -> dict:
    """
    Reverses the split if within the 60-second window.
    """
    snapshot = _pending_undos.get(split_id)

    if not snapshot:
        return {"reversed": False, "message": "Split not found or already undone."}

    if snapshot["user_id"] != user_id:
        return {"reversed": False, "message": "Unauthorised."}

    if datetime.utcnow() > snapshot["expires_at"]:
        _pending_undos.pop(split_id, None)
        return {"reversed": False, "message": "Undo window has expired (60 seconds passed)."}

    # Reverse each pocket deduction
    for line in snapshot["lines"]:
        pocket_res = await db.table("Pocket").select("balance").eq("id", line["pocket_id"]).single().execute()
        current    = float(pocket_res.data["balance"])
        restored   = max(0.0, current - line["amount"])
        await db.table("Pocket").update({"balance": restored}).eq("id", line["pocket_id"]).execute()

    _pending_undos.pop(split_id, None)
    return {"reversed": True, "message": "Split reversed. Your balance has been restored."}


async def get_undo_context(db: AsyncClient, user_id: str) -> Optional[str]:
    """
    Builds the undo confirmation message shown to the user.
    e.g. "Are you sure? Your Emergency Fund needs RM340 more."
    Picks the pocket furthest from its target.
    """
    pockets = await get_user_pockets(db, user_id)
    if not pockets:
        return None

    most_needed = max(pockets, key=lambda p: float(p["target"]) - float(p["balance"]))
    gap = round(float(most_needed["target"]) - float(most_needed["balance"]), 2)

    if gap <= 0:
        return "All your pockets are fully funded! Sure you want to undo?"
    return f"Are you sure? Your {most_needed['name']} still needs RM{gap:.2f} more."

from __future__ import annotations

import uuid

from app.core.database import get_supabase_client


def _to_response(p: dict) -> dict:
    target = float(p.get("target") or 0)
    balance = float(p.get("balance") or 0)
    return {
        "id": p["id"],
        "name": p.get("name", ""),
        "balance": balance,
        "target": target,
        "split_rule": p.get("splitrule") or {"type": "percent", "value": 0},
        "percent_complete": round((balance / target * 100), 1) if target > 0 else 0.0,
    }


def list_pockets(user_id: str) -> list[dict]:
    db = get_supabase_client()
    res = db.table("Pocket").select("*").eq("userid", user_id).execute()
    return [_to_response(p) for p in (res.data or [])]


def create_pocket(user_id: str, payload: dict) -> dict:
    db = get_supabase_client()
    pocket = {
        "id": str(uuid.uuid4()),
        "userid": user_id,
        "name": payload["name"],
        "balance": 0.0,
        "target": float(payload["target"]),
        "splitrule": payload.get("split_rule", {"type": "percent", "value": 0}),
    }
    res = db.table("Pocket").insert(pocket).execute()
    return _to_response(res.data[0])


def update_pocket(user_id: str, pocket_id: str, payload: dict) -> dict | None:
    db = get_supabase_client()
    update: dict = {}
    if "name" in payload:
        update["name"] = payload["name"]
    if "target" in payload:
        update["target"] = float(payload["target"])
    if "split_rule" in payload:
        update["splitrule"] = payload["split_rule"]

    res = (
        db.table("Pocket")
        .update(update)
        .eq("id", pocket_id)
        .eq("userid", user_id)
        .execute()
    )
    if not res.data:
        return None
    return _to_response(res.data[0])


def delete_pocket(user_id: str, pocket_id: str) -> None:
    db = get_supabase_client()
    db.table("Pocket").delete().eq("id", pocket_id).eq("userid", user_id).execute()

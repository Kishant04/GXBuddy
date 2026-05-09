import uuid
from supabase import AsyncClient

async def create_pocket(db: AsyncClient, user_id: str, payload: dict) -> dict:
    pocket = {
        "id":         str(uuid.uuid4()),
        "userid":    user_id,
        "name":       payload["name"],
        "balance":    0.0,
        "target":     payload["target"],
        "splitrule": payload["split_rule"],   # {"type": "percent"|"fixed", "value": float}
    }
    res = await db.table("Pocket").insert(pocket).execute()
    return res.data[0]

async def list_pockets(db: AsyncClient, user_id: str) -> list:
    res = await db.table("Pocket").select("*").eq("userid", user_id).execute()
    pockets = res.data or []
    for p in pockets:
        target  = float(p["target"])
        balance = float(p["balance"])
        p["percent_complete"] = round((balance / target * 100), 1) if target > 0 else 0
    return pockets

async def update_pocket(db: AsyncClient, user_id: str, pocket_id: str, payload: dict) -> dict:
    allowed = {k: v for k, v in payload.items() if k in ("name", "target", "splitrule")}
    res = await db.table("Pocket").update(allowed) \
        .eq("id", pocket_id).eq("userid", user_id).execute()
    return res.data[0] if res.data else {}

async def delete_pocket(db: AsyncClient, user_id: str, pocket_id: str):
    await db.table("Pocket").delete().eq("id", pocket_id).eq("userid", user_id).execute()

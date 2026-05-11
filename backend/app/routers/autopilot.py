from __future__ import annotations

from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Header, Query

from app.core.database import TABLES, get_supabase_client
from app.schemas.contracts import (
    AutopilotConfig,
    AutopilotTriggerRequest,
    AutopilotTriggerResponse,
    AutopilotUndoRequest,
    AutopilotUndoResponse,
)
from app.services.autopilot_service import execute_split, get_undo_context, undo_split
from app.routers.auth import get_current_user, verify_token

router = APIRouter(prefix="/api/autopilot", tags=["autopilot"])


@router.get("/health")
async def autopilot_health():
    return {"status": "Autopilot router working"}


@router.get("/config", response_model=AutopilotConfig)
async def get_config(
    user_id: Optional[str] = Query(None),
    authorization: Optional[str] = Header(None),
):
    target_user_id = user_id
    if not target_user_id:
        if not authorization:
            raise HTTPException(status_code=401, detail="Missing user_id or Authorization header")
        try:
            token = authorization.replace("Bearer ", "")
            user = verify_token(token)
            target_user_id = user["id"]
        except Exception:
            raise HTTPException(status_code=401, detail="Authentication failed")

    db = get_supabase_client()
    res = db.table("User").select("salarythreshold, incometype").eq("id", target_user_id).limit(1).execute()
    if not res.data:
        return AutopilotConfig(salary_threshold=800, income_type="monthly")
    
    row = res.data[0]
    return AutopilotConfig(
        salary_threshold=float(row.get("salarythreshold") or 800),
        income_type=str(row.get("incometype") or "monthly").lower()
    )


@router.patch("/config", response_model=AutopilotConfig)
async def update_config(
    payload: AutopilotConfig,
    user_id: Optional[str] = Query(None),
    authorization: Optional[str] = Header(None),
):
    target_user_id = user_id
    if not target_user_id:
        if not authorization:
            raise HTTPException(status_code=401, detail="Missing user_id or Authorization header")
        try:
            token = authorization.replace("Bearer ", "")
            user = verify_token(token)
            target_user_id = user["id"]
        except Exception:
            raise HTTPException(status_code=401, detail="Authentication failed")

    db = get_supabase_client()
    update = {
        "salarythreshold": payload.salary_threshold,
        "incometype": payload.income_type.upper()
    }
    db.table("User").update(update).eq("id", target_user_id).execute()
    return payload


@router.post("/trigger", response_model=AutopilotTriggerResponse)
async def trigger_split(
    payload: AutopilotTriggerRequest,
    authorization: Optional[str] = Header(None),
):
    """
    Fires the salary split for the given salary transaction.
    Requires the salary transaction_id to look up the amount.
    """
    target_user_id = payload.user_id
    if not target_user_id:
        if not authorization:
            raise HTTPException(status_code=401, detail="Missing user_id or Authorization header")
        try:
            token = authorization.replace("Bearer ", "")
            user = verify_token(token)
            target_user_id = user["id"]
        except Exception:
            raise HTTPException(status_code=401, detail="Authentication failed")

    db = get_supabase_client()
    txn_res = (
        db.table(TABLES["transactions"])
        .select("amount, category")
        .eq("id", payload.transaction_id)
        .limit(1)
        .execute()
    )
    if not txn_res.data:
        raise HTTPException(404, "Transaction not found.")

    tx = txn_res.data[0]
    category = str(tx.get("category") or "").upper()
    if category != "SALARY":
        raise HTTPException(400, "Transaction is not a salary credit.")

    result = execute_split(target_user_id, float(tx["amount"]))
    if "error" in result:
        raise HTTPException(400, result["error"])
    return result


@router.post("/undo", response_model=AutopilotUndoResponse)
async def undo(
    payload: AutopilotUndoRequest,
    authorization: Optional[str] = Header(None),
):
    target_user_id = payload.user_id
    if not target_user_id:
        if not authorization:
            raise HTTPException(status_code=401, detail="Missing user_id or Authorization header")
        try:
            token = authorization.replace("Bearer ", "")
            user = verify_token(token)
            target_user_id = user["id"]
        except Exception:
            raise HTTPException(status_code=401, detail="Authentication failed")

    return undo_split(target_user_id, payload.split_id)


@router.get("/undo-context")
async def undo_context(
    user_id: Optional[str] = Query(None),
    authorization: Optional[str] = Header(None),
):
    target_user_id = user_id
    if not target_user_id:
        if not authorization:
            raise HTTPException(status_code=401, detail="Missing user_id or Authorization header")
        try:
            token = authorization.replace("Bearer ", "")
            user = verify_token(token)
            target_user_id = user["id"]
        except Exception:
            raise HTTPException(status_code=401, detail="Authentication failed")

    msg = get_undo_context(target_user_id)
    return {"message": msg or "Every ringgit saved today is a step towards freedom. Are you sure?"}

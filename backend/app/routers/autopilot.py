from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException

from app.core.database import TABLES, get_supabase_client
from app.schemas.contracts import (
    AutopilotTriggerRequest,
    AutopilotTriggerResponse,
    AutopilotUndoRequest,
    AutopilotUndoResponse,
)
from app.services.autopilot_service import execute_split, get_undo_context, undo_split
from app.routers.auth import get_current_user

router = APIRouter(prefix="/api/autopilot", tags=["autopilot"])


@router.get("/health")
async def autopilot_health():
    return {"status": "Autopilot router working"}


@router.post("/trigger", response_model=AutopilotTriggerResponse)
async def trigger_split(
    payload: AutopilotTriggerRequest,
    user=Depends(get_current_user),
):
    """
    Fires the salary split for the given salary transaction.
    Requires the salary transaction_id to look up the amount.
    """
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

    result = execute_split(user["id"], float(tx["amount"]))
    if "error" in result:
        raise HTTPException(400, result["error"])
    return result


@router.post("/undo", response_model=AutopilotUndoResponse)
async def undo(
    payload: AutopilotUndoRequest,
    user=Depends(get_current_user),
):
    return undo_split(user["id"], payload.split_id)


@router.get("/undo-context")
async def undo_context(user=Depends(get_current_user)):
    msg = get_undo_context(user["id"])
    return {"message": msg or "Every ringgit saved today is a step towards freedom. Are you sure?"}

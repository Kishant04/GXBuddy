from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException

from app.schemas.contracts import (
    AutopilotTriggerRequest,
    AutopilotTriggerResponse,
    AutopilotUndoRequest,
    AutopilotUndoResponse,
)
from app.services.autopilot_service import execute_split, get_undo_context, undo_split
from app.routers.auth import get_current_user, get_db

router = APIRouter(prefix="/api/autopilot", tags=["autopilot"])


@router.get("/health")
async def autopilot_health():
    return {"status": "Autopilot router working"}


@router.post("/trigger", response_model=AutopilotTriggerResponse)
async def trigger_split(
    payload: AutopilotTriggerRequest,
    db=Depends(get_db),
    user=Depends(get_current_user),
):
    """
    Manually fires the salary split (also auto-fires from POST /api/transactions).
    Used for demo / testing without needing a real salary transaction.
    Requires the salary transaction_id to look up the amount.
    """
    txn_res = (
        await db.table("transactions")
        .select("amount, category")
        .eq("id", payload.transaction_id)
        .single()
        .execute()
    )
    if not txn_res.data:
        raise HTTPException(404, "Transaction not found.")
    if txn_res.data["category"] != "salary":
        raise HTTPException(400, "Transaction is not a salary credit.")

    result = await execute_split(db, user["id"], float(txn_res.data["amount"]))
    if "error" in result:
        raise HTTPException(400, result["error"])
    return result


@router.post("/undo", response_model=AutopilotUndoResponse)
async def undo(
    payload: AutopilotUndoRequest,
    db=Depends(get_db),
    user=Depends(get_current_user),
):
    return await undo_split(db, user["id"], payload.split_id)


@router.get("/undo-context")
async def undo_context(
    db=Depends(get_db),
    user=Depends(get_current_user),
):
    """Returns the motivational message shown before the undo button."""
    msg = await get_undo_context(db, user["id"])
    return {"message": msg}
from __future__ import annotations

from fastapi import APIRouter, Depends, Query, Header, HTTPException
from typing import Optional
from app.schemas.contracts import (
    TransactionCreateRequest,
    TransactionProcessResponse,
    TransactionsListResponse,
)
from app.services.transaction_service import TransactionService
from app.routers.auth import get_current_user, verify_token
from app.core.config import settings

router = APIRouter(prefix="/api/transactions", tags=["transactions"])

transaction_service = TransactionService()


@router.post("", response_model=TransactionProcessResponse)
async def create_transaction(
    payload: TransactionCreateRequest,
    authorization: Optional[str] = Header(None),
) -> TransactionProcessResponse:
    # 1. If user_id is in payload (Demo Mode), use it
    if payload.user_id:
        return await transaction_service.process_transaction(payload)

    # 2. Otherwise, try to get user from JWT
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing user_id in payload or Authorization header")
    
    try:
        token = authorization.replace("Bearer ", "")
        user = verify_token(token)
        payload.user_id = user["id"]
        return await transaction_service.process_transaction(payload)
    except Exception:
        raise HTTPException(status_code=401, detail="Authentication failed")


@router.get("", response_model=TransactionsListResponse)
def list_transactions(
    user_id: str = Query(...),
    limit: int = Query(default=30, ge=1, le=100),
) -> TransactionsListResponse:
    return transaction_service.list_transactions(user_id=user_id, limit=limit)
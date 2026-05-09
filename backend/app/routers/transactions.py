from __future__ import annotations

from fastapi import APIRouter, Depends, Query

from app.schemas.contracts import (
    TransactionCreateRequest,
    TransactionProcessResponse,
    TransactionsListResponse,
)
from app.services.transaction_service import TransactionService
from app.routers.auth import get_current_user

router = APIRouter(prefix="/api/transactions", tags=["transactions"])

transaction_service = TransactionService()


@router.post("", response_model=TransactionProcessResponse)
async def create_transaction(
    payload: TransactionCreateRequest,
    user=Depends(get_current_user),
) -> TransactionProcessResponse:
    # Inject authenticated user_id if not supplied
    if not payload.user_id:
        payload.user_id = user["id"]
    return await transaction_service.process_transaction(payload)


@router.get("", response_model=TransactionsListResponse)
def list_transactions(
    user_id: str = Query(...),
    limit: int = Query(default=30, ge=1, le=100),
) -> TransactionsListResponse:
    return transaction_service.list_transactions(user_id=user_id, limit=limit)
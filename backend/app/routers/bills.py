from __future__ import annotations

from fastapi import APIRouter, Query

from app.schemas.contracts import BillsResponse
from app.services.bill_service import BillService

router = APIRouter(prefix="/bills", tags=["bills"])
bill_service = BillService()


@router.get("", response_model=BillsResponse)
def get_bills(user_id: str = Query(...), days_ahead: int = Query(default=7, ge=1, le=30)) -> BillsResponse:
	upcoming = bill_service.get_upcoming_bills(user_id=user_id, days_ahead=days_ahead)
	warnings = bill_service.get_bill_warnings(user_id=user_id)
	return BillsResponse(upcoming_bills=upcoming, warnings=warnings)

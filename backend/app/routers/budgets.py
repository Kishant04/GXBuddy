from __future__ import annotations

from fastapi import APIRouter, HTTPException, Query

from app.schemas.contracts import BudgetUpsertRequest, BudgetUpsertResponse, BudgetsResponse
from app.services.budget_service import BudgetService

router = APIRouter(prefix="/budgets", tags=["budgets"])
budget_service = BudgetService()


@router.get("", response_model=BudgetsResponse)
def get_budgets(user_id: str = Query(...)) -> BudgetsResponse:
	try:
		return BudgetsResponse(items=budget_service.get_budget_snapshot(user_id=user_id))
	except Exception as exc:
		raise HTTPException(status_code=500, detail=f"Failed to fetch budgets: {exc}") from exc


@router.post("", response_model=BudgetUpsertResponse)
def upsert_budget(payload: BudgetUpsertRequest) -> BudgetUpsertResponse:
	try:
		item = budget_service.upsert_budget(payload)
		return BudgetUpsertResponse(item=item)
	except Exception as exc:
		raise HTTPException(status_code=500, detail=f"Failed to upsert budget: {exc}") from exc

from __future__ import annotations

from fastapi import APIRouter, HTTPException, Query

from app.schemas.contracts import DashboardResponse
from app.services.dashboard_service import DashboardService

router = APIRouter(prefix="/api/dashboard", tags=["dashboard"])
dashboard_service = DashboardService()


@router.get("", response_model=DashboardResponse)
def get_dashboard(user_id: str = Query(..., min_length=1)) -> DashboardResponse:
    try:
        return dashboard_service.get_dashboard(user_id=user_id)
    except Exception as exc:
        raise HTTPException(status_code=500, detail="Failed to load dashboard.") from exc

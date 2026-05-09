from __future__ import annotations
from fastapi import APIRouter, HTTPException, Query
from app.schemas.contracts import AlertItem, AlertsResponse
from app.services.alert_service import AlertService

router = APIRouter(prefix="/alerts", tags=["alerts"])
alert_service = AlertService()

@router.get("", response_model=AlertsResponse)
def get_alerts(
	user_id: str = Query(...),
	severity: str | None = Query(default=None),
	limit: int = Query(default=20, ge=1, le=100),
) -> AlertsResponse:
	return AlertsResponse(items=alert_service.fetch_recent_alerts(user_id=user_id, severity=severity, limit=limit))


@router.post("/{alert_id}/actioned", response_model=AlertItem)
def action_alert(alert_id: str) -> AlertItem:
	updated = alert_service.mark_actioned(alert_id)
	if not updated:
		raise HTTPException(status_code=404, detail="Alert not found")
	return updated

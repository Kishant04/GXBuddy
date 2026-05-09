from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict

from app.schemas.common import AlertSeverity


class AlertCreateRequest(BaseModel):
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "user_id": "b5e4f6b5-dc2b-4427-a7bc-ef0cb756d17a",
                "message": "You reached 80% of weekly budget.",
                "severity": "alert",
            }
        }
    )

    user_id: str
    message: str
    severity: AlertSeverity


class AlertResponse(BaseModel):
    id: str
    user_id: str
    message: str
    severity: AlertSeverity
    action_taken: bool = False
    created_at: datetime


class AlertsResponse(BaseModel):
    items: list[AlertResponse]

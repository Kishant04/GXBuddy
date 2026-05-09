from __future__ import annotations

from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field

from app.schemas.common import AlertSeverity


class BillReminderResponse(BaseModel):
    id: str
    name: str
    amount: Decimal = Field(ge=Decimal("0"), decimal_places=2)
    due_date: datetime
    days_remaining: int
    is_paid: bool


class BillWarningResponse(BaseModel):
    bill_id: str
    message: str
    severity: AlertSeverity = AlertSeverity.ALERT
    days_remaining: int


class BillsResponse(BaseModel):
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "upcoming_bills": [
                    {
                        "id": "bill_123",
                        "name": "Celcom",
                        "amount": "98.00",
                        "due_date": "2026-05-10T00:00:00Z",
                        "days_remaining": 2,
                        "is_paid": False,
                    }
                ],
                "warnings": [
                    {
                        "bill_id": "bill_123",
                        "message": "Your Celcom bill is due in 2 day(s), spend wisely.",
                        "severity": "alert",
                        "days_remaining": 2,
                    }
                ],
            }
        }
    )

    upcoming_bills: list[BillReminderResponse]
    warnings: list[BillWarningResponse]

from __future__ import annotations

from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field

from app.schemas.alert import AlertResponse
from app.schemas.bill import BillReminderResponse
from app.schemas.common import CategorySpend, MascotResponse, StreakSummary
from app.schemas.transaction import TransactionRead


class PocketSummary(BaseModel):
    """Savings pocket shown on the home screen."""

    id: str
    name: str
    balance: Decimal = Field(ge=Decimal("0"), decimal_places=2)
    target: Decimal = Field(ge=Decimal("0"), decimal_places=2)
    progress_percent: float = Field(ge=0, le=100)


class DashboardResponse(BaseModel):
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "mascot": {
                    "state": "alert",
                    "mood_line": "Careful ya, spending is climbing. Keep some room for bills.",
                },
                "weekly_spend_total": "248.00",
                "weekly_budget_limit": "350.00",
                "weekly_budget_used_percent": 70.86,
                "category_breakdown": [
                    {"category": "food", "amount": "148.00"},
                    {"category": "transport", "amount": "40.00"},
                ],
                "upcoming_bills": [],
                "recent_alerts": [],
                "pocket_summaries": [],
                "streak_summary": {
                    "current_streak": 3,
                    "best_streak": 7,
                    "last_save_date": None,
                },
            }
        }
    )

    mascot: MascotResponse
    weekly_spend_total: Decimal = Field(ge=Decimal("0"), decimal_places=2)
    weekly_budget_limit: Decimal = Field(ge=Decimal("0"), decimal_places=2)
    weekly_budget_used_percent: float = Field(ge=0)
    category_breakdown: list[CategorySpend]
    upcoming_bills: list[BillReminderResponse]
    recent_alerts: list[AlertResponse]
    pocket_summaries: list[PocketSummary]
    streak_summary: StreakSummary
    recent_transactions: list[TransactionRead] = Field(default_factory=list)

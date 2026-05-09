from __future__ import annotations

from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field, field_validator


class BudgetCreateRequest(BaseModel):
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "user_id": "b5e4f6b5-dc2b-4427-a7bc-ef0cb756d17a",
                "scope": "overall",
                "weekly_limit": "350.00",
                "category": None,
                "alert60": False,
                "alert80": False,
                "alert100": False,
            }
        }
    )

    user_id: str
    scope: str
    weekly_limit: Decimal = Field(gt=Decimal("0"), decimal_places=2)
    category: str | None = None
    period_start: datetime | None = None
    period_end: datetime | None = None
    alert60: bool = False
    alert80: bool = False
    alert100: bool = False

    @field_validator("scope", mode="before")
    @classmethod
    def normalize_scope(cls, value: str) -> str:
        # Database enum labels are lowercase; accept common user casing.
        raw = str(value).strip().lower()
        aliases = {
            "overall": "overall",
            "category": "category",
        }
        return aliases.get(raw, raw)


class BudgetProgress(BaseModel):
    budget_id: str
    category: str | None = None
    weekly_limit: Decimal = Field(ge=Decimal("0"), decimal_places=2)
    spent_amount: Decimal = Field(ge=Decimal("0"), decimal_places=2)
    usage_percent: float = Field(ge=0)


class ThresholdEvent(BaseModel):
    budget_id: str
    threshold: int
    usage_percent: float = Field(ge=0)
    message: str


class BudgetResponse(BaseModel):
    item: BudgetProgress


class BudgetsResponse(BaseModel):
    items: list[BudgetProgress]

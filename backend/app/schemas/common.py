from __future__ import annotations

from datetime import datetime
from decimal import Decimal
from enum import Enum
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class MascotState(str, Enum):
    CALM = "calm"
    ALERT = "alert"
    PANICKED = "panicked"
    CELEBRATING = "celebrating"


class AlertSeverity(str, Enum):
    CALM = "calm"
    ALERT = "alert"
    PANICKED = "panicked"
    CELEBRATING = "celebrating"
    EMERGENCY = "emergency"


class TransactionCategory(str, Enum):
    FOOD = "FOOD"
    TRANSPORT = "TRANSPORT"
    SHOPPING = "SHOPPING"
    ENTERTAINMENT = "ENTERTAINMENT"
    BILLS = "BILLS"
    HEALTH = "HEALTH"
    EDUCATION = "EDUCATION"
    GROCERIES = "GROCERIES"
    SAVINGS = "SAVINGS"
    SALARY = "SALARY"
    OTHER = "OTHER"


class TransactionSource(str, Enum):
    MANUAL = "MANUAL"
    GRAB = "GRAB"
    SHOPEE = "SHOPEE"
    BANK = "BANK"
    CARD = "CARD"
    FPX = "FPX"
    DUITNOW = "DUITNOW"
    OTHER = "OTHER"


class TransactionStatus(str, Enum):
    POSTED = "POSTED"
    PENDING = "PENDING"
    FAILED = "FAILED"
    REVERSED = "REVERSED"


class SpendingClass(str, Enum):
    ESSENTIAL = "essential"
    LIFESTYLE = "lifestyle"
    RISKY = "risky"
    UNUSUAL = "unusual"
    SALARY = "salary"
    BILL = "bill"


class RiskBand(str, Enum):
    CALM = "calm"
    ALERT = "alert"
    PANICKED = "panicked"
    EMERGENCY = "emergency"


class WebSocketEventType(str, Enum):
    ALERT = "alert"
    MASCOT_STATE = "mascot_state"
    BILL_WARNING = "bill_warning"
    TRANSACTION_PROCESSED = "transaction_processed"


class MascotResponse(BaseModel):
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "state": "alert",
                "mood_line": "Careful ya, spending is climbing. Keep some room for bills.",
            }
        }
    )

    state: MascotState
    mood_line: str


class CategorySpend(BaseModel):
    category: str
    amount: Decimal = Field(ge=Decimal("0"), decimal_places=2)


class StreakSummary(BaseModel):
    current_streak: int = 0
    best_streak: int = 0
    last_save_date: datetime | None = None


class WebSocketEvent(BaseModel):
    """
    Internal event model. Serialise with model_dump(mode="json", by_alias=True)
    before sending over the wire so Flutter receives {"type", "data", "timestamp"}.
    """

    model_config = ConfigDict(populate_by_name=True)

    # 'type' is reserved in Python, so we keep the internal name as 'event'
    # and expose it as 'type' in the JSON payload Flutter reads.
    event: WebSocketEventType = Field(serialization_alias="type")
    user_id: str
    # Internal name stays 'payload'; Flutter receives it as 'data'.
    payload: dict[str, Any] = Field(serialization_alias="data")
    timestamp: datetime = Field(default_factory=datetime.utcnow)

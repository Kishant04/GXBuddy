from __future__ import annotations

from typing import List

from pydantic import BaseModel

# Compatibility layer for existing imports across services/routers.

from app.schemas.alert import AlertCreateRequest, AlertResponse, AlertsResponse
from app.schemas.bill import BillReminderResponse, BillWarningResponse, BillsResponse
from app.schemas.budget import (
    BudgetCreateRequest,
    BudgetProgress,
    BudgetResponse,
    BudgetsResponse,
    ThresholdEvent,
)
from app.schemas.common import (
    AlertSeverity,
    CategorySpend,
    MascotResponse,
    MascotState,
    RiskBand,
    SpendingClass,
    StreakSummary,
    TransactionCategory,
    TransactionSource,
    TransactionStatus,
    WebSocketEvent,
    WebSocketEventType,
)
from app.schemas.dashboard import DashboardResponse
from app.schemas.transaction import (
    ClassificationResult,
    NudgeResponse,
    RiskResult,
    TransactionCreateRequest,
    TransactionRead,
    TransactionResponse,
    TransactionsListResponse,
)

# Legacy aliases used by the current service layer.
MascotStatus = MascotResponse
AlertItem = AlertResponse
UpcomingBill = BillReminderResponse
BillWarning = BillWarningResponse
BudgetUpsertRequest = BudgetCreateRequest
BudgetUpsertResponse = BudgetResponse
TransactionRecord = TransactionRead
TransactionProcessResponse = TransactionResponse
RiskResultSchema = RiskResult


class SplitLineItem(BaseModel):
    pocket_id: str
    pocket_name: str
    amount: float
    rule_type: str  # "percent" | "fixed"
    rule_value: float


class AutopilotTriggerRequest(BaseModel):
    transaction_id: str  # the salary transaction that fired this


class AutopilotTriggerResponse(BaseModel):
    split_id: str
    total_routed: float
    lines: List[SplitLineItem]
    undo_deadline: str  # ISO timestamp — 60s from now


class AutopilotUndoRequest(BaseModel):
    split_id: str


class AutopilotUndoResponse(BaseModel):
    reversed: bool
    message: str
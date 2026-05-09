from __future__ import annotations

from datetime import datetime
from decimal import Decimal
from typing import List, Optional

from pydantic import BaseModel

from app.schemas.common import (
    AlertSeverity,
    MascotResponse,
    SpendingClass,
    TransactionCategory,
    TransactionSource,
    TransactionStatus,
)


class TransactionCreateRequest(BaseModel):
    user_id: Optional[str] = None
    amount: float
    merchant: str
    category: Optional[TransactionCategory] = None
    source: TransactionSource = TransactionSource.MANUAL
    status: TransactionStatus = TransactionStatus.POSTED
    external_ref: Optional[str] = None
    is_bnpl: bool = False
    timestamp: Optional[datetime] = None


class TransactionRead(BaseModel):
    id: str
    user_id: str
    amount: Decimal
    merchant: str
    category: str
    source: str
    status: str
    external_ref: Optional[str] = None
    risk_score: Optional[float] = None
    category_confidence: Optional[float] = None
    is_bnpl: bool = False
    alert_generated: bool = False
    timestamp: datetime


class ClassificationResult(BaseModel):
    primary: SpendingClass
    confidence: float
    tags: Optional[List[SpendingClass]] = None
    reason: Optional[str] = None


class NudgeResponse(BaseModel):
    message: str
    severity: AlertSeverity
    action: Optional[str] = None


class RiskResult(BaseModel):
    score: float
    band: Optional[str] = None
    reasons: Optional[List[str]] = None


class TransactionResponse(BaseModel):
    transaction: TransactionRead
    classification: str
    risk_score: float
    mascot: MascotResponse
    alert: Optional[NudgeResponse] = None
    classification_details: Optional[ClassificationResult] = None
    risk_details: Optional[RiskResult] = None
    alerts: Optional[List] = None
    budget_progress: Optional[List] = None
    threshold_events: Optional[List] = None
    websocket_events: Optional[List] = None


class TransactionsListResponse(BaseModel):
    items: List[TransactionRead]


class TransactionProcessResponse(TransactionResponse):
    pass
from __future__ import annotations

from datetime import datetime, timedelta
from decimal import Decimal


def to_decimal(value: object | None) -> Decimal:
    if value is None:
        return Decimal("0")
    if isinstance(value, Decimal):
        return value
    return Decimal(str(value))


def to_float(value: object | None) -> float:
    if value is None:
        return 0.0
    if isinstance(value, Decimal):
        return float(value)
    return float(value)


def clamp(value: float, low: float, high: float) -> float:
    return max(low, min(high, value))


def safe_percent(numerator: float, denominator: float) -> float:
    if denominator <= 0:
        return 0.0
    return (numerator / denominator) * 100


def safe_percent_decimal(numerator: Decimal, denominator: Decimal) -> float:
    if denominator <= 0:
        return 0.0
    return float((numerator / denominator) * Decimal("100"))


def week_bounds(reference: datetime | None = None) -> tuple[datetime, datetime]:
    now = reference or datetime.utcnow()
    # Use a rolling 7-day window ending at the current moment
    start = now - timedelta(days=7)
    return start, now


def is_late_night(ts: datetime) -> bool:
    return ts.hour >= 23 or ts.hour < 5


def days_until(target: datetime, reference: datetime | None = None) -> int:
    now = reference or datetime.utcnow()
    delta = target.date() - now.date()
    return delta.days

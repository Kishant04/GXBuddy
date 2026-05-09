from __future__ import annotations

"""Validation and normalization helpers shared across Feature 1 AI modules.

These helpers keep classification, risk scoring, mascot state selection, and nudge
output deterministic and safe before any optional LLM wording fallback is attempted.
"""

from datetime import datetime


def normalize_text(value: str | None) -> str:
    """Return a trimmed lowercase string for matching rules safely."""
    return (value or "").strip().lower()


def require_non_empty_text(value: str | None, field_name: str) -> str:
    """Validate that a text field is present and non-empty."""
    normalized = (value or "").strip()
    if not normalized:
        raise ValueError(f"{field_name} must not be empty")
    return normalized


def require_non_negative_number(value: float, field_name: str) -> float:
    """Validate that a numeric field is non-negative."""
    if value < 0:
        raise ValueError(f"{field_name} must be non-negative")
    return value


def require_positive_number(value: float, field_name: str) -> float:
    """Validate that a numeric field is strictly positive."""
    if value <= 0:
        raise ValueError(f"{field_name} must be greater than zero")
    return value


def hour_of_day(timestamp: datetime) -> int:
    """Return the hour component for time-based rules."""
    return timestamp.hour


def is_late_night(timestamp: datetime) -> bool:
    """Return True for late-night spending windows used by risk rules."""
    return hour_of_day(timestamp) >= 23 or hour_of_day(timestamp) < 5


def time_of_day_bucket(timestamp: datetime) -> str:
    """Map a timestamp to a simple part-of-day label for prompts and rules."""
    hour = hour_of_day(timestamp)
    if 5 <= hour < 12:
        return "morning"
    if 12 <= hour < 17:
        return "afternoon"
    if 17 <= hour < 23:
        return "evening"
    return "late_night"

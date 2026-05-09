from __future__ import annotations

"""Short contextual nudge generation for Feature 1.

This module keeps trigger thresholds deterministic. Optional AI is used only to rewrite
the human-facing message and never to compute money values or severity.
"""

from dataclasses import dataclass

from app.ai.prompts import (
	PAUSE_AND_THINK_ACTION,
	REVIEW_BUDGET_ACTION,
	ROUND_UP_ACTION,
	SLOW_DOWN_ACTION,
	llm_json_completion,
)
from app.ai.validators import require_non_negative_number
from app.schemas.contracts import AlertSeverity, NudgeResponse


@dataclass
class NudgeInput:
	"""Context inputs used to produce a short frontend-safe nudge."""

	category: str
	amount: float
	budget_used_percent: float
	average_spend: float
	time_of_day: int
	upcoming_bills_count: int
	risk_score: float
	weekly_frequency: int


def _rewrite_message_with_ai(template_message: str, severity: AlertSeverity, action: str) -> str | None:
	"""Optionally rewrite a nudge message with the configured LLM."""
	result = llm_json_completion(
		system_prompt=(
			"Rewrite a financial nudge in short Malaysian-English. Return JSON with key message only. "
			"Keep it under 140 characters and do not change severity or action."
		),
		user_prompt=f"severity={severity.value}\naction={action}\nmessage={template_message}",
	)
	if not result:
		return None
	message = str(result.get("message", "")).strip()
	return message or None


def generate_nudge(data: NudgeInput) -> NudgeResponse | None:
	"""Generate a structured nudge when a risk threshold is crossed."""
	require_non_negative_number(data.amount, "amount")
	require_non_negative_number(data.budget_used_percent, "budget_used_percent")
	require_non_negative_number(data.average_spend, "average_spend")
	require_non_negative_number(data.upcoming_bills_count, "upcoming_bills_count")
	require_non_negative_number(data.risk_score, "risk_score")
	require_non_negative_number(data.weekly_frequency, "weekly_frequency")

	if data.risk_score < 40 and data.budget_used_percent < 60:
		return None

	if data.risk_score >= 90:
		message = (
			f"Spending quite intense now. This {data.category} charge may push you further off-track. "
			"Pause 10 seconds and decide again?"
		)
		severity = AlertSeverity.EMERGENCY
		action = PAUSE_AND_THINK_ACTION
	elif data.time_of_day >= 23 or data.time_of_day < 5:
		message = (
			f"Late-night {data.category} spend detected. You are at {data.budget_used_percent:.0f}% of weekly budget. "
			"Round up RM2 into savings first?"
		)
		severity = AlertSeverity.ALERT
		action = ROUND_UP_ACTION
	elif data.weekly_frequency >= 3 and data.risk_score >= 50:
		message = (
			f"{data.weekly_frequency}th {data.category} spend this week. Budget usage now {data.budget_used_percent:.0f}%. "
			"Want to cap this category for the weekend?"
		)
		severity = AlertSeverity.ALERT
		action = REVIEW_BUDGET_ACTION
	elif data.upcoming_bills_count > 0 and data.budget_used_percent >= 70:
		message = "Bills due soon, spend wisely first ya. Keep some buffer before checkout."
		severity = AlertSeverity.ALERT
		action = SLOW_DOWN_ACTION
	else:
		message = "You are getting close to the weekly cap. One small save move now helps later."
		severity = AlertSeverity.CALM
		action = ROUND_UP_ACTION

	ai_message = _rewrite_message_with_ai(message, severity, action)
	if ai_message is not None:
		message = ai_message

	return NudgeResponse(message=message, severity=severity, action=action)

from __future__ import annotations

"""Mascot state engine for Feature 1.

State selection is fully deterministic. Optional AI is only used to rewrite the mood
line, and the engine always falls back to a safe local template.
"""

from dataclasses import dataclass

from app.ai.prompts import llm_json_completion
from app.ai.validators import require_non_negative_number
from app.schemas.contracts import MascotState, MascotStatus


@dataclass
class MascotInput:
	"""Inputs used to map financial pressure into a mascot state and mood line."""

	weekly_percentage_used: float
	savings_streak_days: int
	upcoming_bill_due_soon: bool
	weekly_alert_count: int
	risk_score: float


def _mood_line_for_state(state: MascotState, weekly_percentage_used: float) -> str:
	"""Return a deterministic fallback mood line for the given mascot state."""
	if state == MascotState.CELEBRATING:
		return "Steady la! You are building a strong money habit this week."
	if state == MascotState.PANICKED:
		return f"Aiyo, budget at {weekly_percentage_used:.0f}% already. Let us slow down first."
	if state == MascotState.ALERT:
		return "Careful ya, spending is climbing. Keep some room for bills."
	return "Nice and chill. You are tracking well this week."


def _maybe_generate_ai_mood_line(state: MascotState, weekly_percentage_used: float, risk_score: float) -> str | None:
	"""Use the configured LLM to rewrite the mood line, or return None on failure."""
	result = llm_json_completion(
		system_prompt=(
			"Write one short Malaysian-English mascot mood line. Return JSON with key mood_line only. "
			"Do not mention exact calculations beyond the provided numbers."
		),
		user_prompt=(
			f"state={state.value}\nweekly_percentage_used={weekly_percentage_used:.0f}\nrisk_score={risk_score:.0f}"
		),
	)
	if not result:
		return None
	mood_line = str(result.get("mood_line", "")).strip()
	return mood_line or None


def determine_mascot_state(data: MascotInput) -> MascotStatus:
	"""Return a deterministic mascot state and a safe mood line."""
	require_non_negative_number(data.weekly_percentage_used, "weekly_percentage_used")
	require_non_negative_number(data.savings_streak_days, "savings_streak_days")
	require_non_negative_number(data.weekly_alert_count, "weekly_alert_count")
	require_non_negative_number(data.risk_score, "risk_score")

	if data.weekly_percentage_used > 100 or data.risk_score >= 70:
		state = MascotState.PANICKED
	elif data.savings_streak_days > 7 and data.risk_score < 40:
		state = MascotState.CELEBRATING
	elif data.upcoming_bill_due_soon and data.weekly_percentage_used >= 70:
		state = MascotState.ALERT
	elif data.risk_score >= 40 or data.weekly_alert_count >= 2:
		state = MascotState.ALERT
	else:
		state = MascotState.CALM

	mood_line = _maybe_generate_ai_mood_line(state, data.weekly_percentage_used, data.risk_score)
	if mood_line is None:
		mood_line = _mood_line_for_state(state, data.weekly_percentage_used)

	return MascotStatus(state=state, mood_line=mood_line)

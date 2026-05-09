from __future__ import annotations

from datetime import datetime
from decimal import Decimal

from app.ai.mascot_engine import MascotInput, determine_mascot_state
from app.ai.nudge_generator import NudgeInput, generate_nudge
from app.ai.spending_classifier import ClassificationInput, classify_spending
from app.schemas.common import AlertSeverity, MascotState, SpendingClass
from app.services.budget_service import BudgetService


def test_low_spend_transaction_keeps_mascot_calm(monkeypatch) -> None:
	monkeypatch.setattr("app.ai.mascot_engine.llm_json_completion", lambda **_: None)

	mascot = determine_mascot_state(
		MascotInput(
			weekly_percentage_used=22,
			savings_streak_days=2,
			upcoming_bill_due_soon=False,
			weekly_alert_count=0,
			risk_score=18,
		)
	)

	assert mascot.state == MascotState.CALM


def test_spending_at_60_percent_triggers_alert_state(monkeypatch) -> None:
	monkeypatch.setattr("app.ai.mascot_engine.llm_json_completion", lambda **_: None)

	mascot = determine_mascot_state(
		MascotInput(
			weekly_percentage_used=60,
			savings_streak_days=0,
			upcoming_bill_due_soon=False,
			weekly_alert_count=1,
			risk_score=45,
		)
	)

	assert mascot.state == MascotState.ALERT


def test_spending_at_80_percent_triggers_stronger_alert(monkeypatch) -> None:
	monkeypatch.setattr("app.ai.mascot_engine.llm_json_completion", lambda **_: None)

	mascot = determine_mascot_state(
		MascotInput(
			weekly_percentage_used=80,
			savings_streak_days=0,
			upcoming_bill_due_soon=False,
			weekly_alert_count=2,
			risk_score=72,
		)
	)

	assert mascot.state == MascotState.PANICKED


def test_spending_above_100_percent_triggers_panicked(monkeypatch) -> None:
	monkeypatch.setattr("app.ai.mascot_engine.llm_json_completion", lambda **_: None)

	mascot = determine_mascot_state(
		MascotInput(
			weekly_percentage_used=105,
			savings_streak_days=0,
			upcoming_bill_due_soon=False,
			weekly_alert_count=0,
			risk_score=35,
		)
	)

	assert mascot.state == MascotState.PANICKED


def test_late_night_grabfood_transaction_produces_risky_alert(monkeypatch) -> None:
	monkeypatch.setattr("app.ai.spending_classifier.llm_json_completion", lambda **_: None)
	monkeypatch.setattr("app.ai.nudge_generator.llm_json_completion", lambda **_: None)

	tx_time = datetime(2026, 5, 8, 23, 30, 0)
	classification = classify_spending(
		ClassificationInput(
			merchant="GrabFood",
			category="FOOD",
			amount=35.0,
			timestamp=tx_time,
			source="GRAB",
			historical_average=20.0,
			weekly_frequency=3,
		)
	)
	nudge = generate_nudge(
		NudgeInput(
			category=classification.primary.value,
			amount=35.0,
			budget_used_percent=70.0,
			average_spend=20.0,
			time_of_day=23,
			upcoming_bills_count=1,
			risk_score=55.0,
			weekly_frequency=3,
		)
	)

	assert SpendingClass.RISKY in classification.tags
	assert nudge is not None
	assert nudge.severity == AlertSeverity.ALERT


def test_salary_credit_like_transaction_classifies_as_salary(monkeypatch) -> None:
	monkeypatch.setattr("app.ai.spending_classifier.llm_json_completion", lambda **_: None)

	classification = classify_spending(
		ClassificationInput(
			merchant="Maybank Payroll",
			category=None,
			amount=2400.0,
			timestamp=datetime(2026, 5, 8, 9, 0, 0),
			source="BANK",
			historical_average=0.0,
			weekly_frequency=1,
		)
	)

	assert classification.primary == SpendingClass.SALARY


def test_budget_threshold_detection_60_and_80() -> None:
	updates: list[tuple[str, int]] = []

	class StubBudgetService(BudgetService):
		def __init__(self) -> None:
			pass

		def _active_budgets(self, user_id: str, at=None) -> list[dict]:
			return [
				{
					"id": "budget-1",
					"scope": "OVERALL",
					"category": None,
					"weeklyLimit": "100.00",
					"alert60": False,
					"alert80": False,
					"alert100": False,
				}
			]

		def _update_threshold_flag(self, budget_id: str, threshold: int) -> None:
			updates.append((budget_id, threshold))

	service = StubBudgetService()
	_, events = service.get_budget_progress(
		user_id="u1",
		weekly_total=Decimal("80.00"),
		category_totals={},
	)

	thresholds = [event.threshold for event in events]
	assert 60 in thresholds
	assert 80 in thresholds
	assert 100 not in thresholds
	assert updates == [("budget-1", 60), ("budget-1", 80)]

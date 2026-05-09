from __future__ import annotations

from datetime import datetime, timedelta
from decimal import Decimal

from fastapi.testclient import TestClient

from app.main import app
from app.routers import dashboard as dashboard_router_module
from app.schemas.alert import AlertResponse
from app.schemas.bill import BillReminderResponse
from app.schemas.common import AlertSeverity
from app.schemas.dashboard import DashboardResponse, PocketSummary
from app.services.dashboard_service import DashboardService


class _Result:
	def __init__(self, data):
		self.data = data


class _StaticQuery:
	def __init__(self, rows: list[dict]) -> None:
		self.rows = rows

	def select(self, _value: str):
		return self

	def eq(self, _k: str, _v):
		return self

	def gte(self, _k: str, _v):
		return self

	def lt(self, _k: str, _v):
		return self

	def order(self, _k: str, desc: bool = False):
		if desc:
			self.rows = sorted(self.rows, key=lambda row: row.get("timestamp", ""), reverse=True)
		return self

	def limit(self, _v: int):
		return self

	def execute(self):
		return _Result(list(self.rows))


class _DashboardClient:
	def __init__(self, transactions: list[dict], streaks: list[dict], pockets: list[dict]) -> None:
		self._transactions = transactions
		self._streaks = streaks
		self._pockets = pockets

	def table(self, table_name: str):
		if table_name == "Transaction":
			return _StaticQuery(self._transactions)
		if table_name == "Streak":
			return _StaticQuery(self._streaks)
		if table_name == "Pocket":
			return _StaticQuery(self._pockets)
		return _StaticQuery([])


class _AlertService:
	def fetch_recent_alerts(self, user_id: str, severity: str | None = None, limit: int = 20):
		return [
			AlertResponse(
				id="a-1",
				user_id=user_id,
				message="You are at 80% weekly budget.",
				severity=AlertSeverity.ALERT,
				action_taken=False,
				created_at=datetime.utcnow(),
			)
		]


class _BillService:
	def get_upcoming_bills(self, user_id: str, days_ahead: int = 7):
		due = datetime.utcnow() + timedelta(days=2)
		return [
			BillReminderResponse(
				id="b-1",
				name="Internet",
				amount=Decimal("89.00"),
				due_date=due,
				days_remaining=2,
				is_paid=False,
			)
		]

	def get_bill_warnings(self, user_id: str):
		return []


class _BudgetService:
	def get_budget_progress(self, user_id: str, weekly_total: Decimal, category_totals: dict[str, Decimal]):
		from app.schemas.budget import BudgetProgress

		return [
			BudgetProgress(
				budget_id="bg-1",
				category=None,
				weekly_limit=Decimal("200.00"),
				spent_amount=weekly_total,
				usage_percent=75.0,
			)
		], []


def test_dashboard_service_includes_due_soon_bill(monkeypatch) -> None:
	monkeypatch.setattr("app.ai.mascot_engine.llm_json_completion", lambda **_: None)

	client = _DashboardClient(
		transactions=[
			{
				"id": "tx-1",
				"userId": "u-1",
				"merchant": "Grab",
				"amount": "40.00",
				"category": "FOOD",
				"source": "GRAB",
				"status": "POSTED",
				"timestamp": datetime.utcnow().isoformat(),
			}
		],
		streaks=[{"currentStreak": 2, "bestStreak": 5, "lastSaveDate": None}],
		pockets=[{"id": "p-1", "name": "Emergency", "balance": "20.00", "target": "100.00"}],
	)

	service = DashboardService(
		client=client,
		alert_service=_AlertService(),
		bill_service=_BillService(),
		budget_service=_BudgetService(),
	)
	response = service.get_dashboard("u-1")

	assert response.upcoming_bills
	assert response.upcoming_bills[0].days_remaining == 2
	assert response.recent_alerts[0].severity == AlertSeverity.ALERT
	assert response.pocket_summaries[0].name == "Emergency"


def test_dashboard_router_response_json_shape() -> None:
	original_service = dashboard_router_module.dashboard_service

	class _StubDashboardService:
		def get_dashboard(self, user_id: str):
			return DashboardResponse(
				mascot={"state": "alert", "mood_line": "Careful ya."},
				weekly_spend_total=Decimal("150.00"),
				weekly_budget_limit=Decimal("250.00"),
				weekly_budget_used_percent=60.0,
				category_breakdown=[{"category": "food", "amount": Decimal("100.00")}],
				upcoming_bills=[
					{
						"id": "b-1",
						"name": "Internet",
						"amount": Decimal("89.00"),
						"due_date": datetime.utcnow(),
						"days_remaining": 2,
						"is_paid": False,
					}
				],
				recent_alerts=[
					{
						"id": "a-1",
						"user_id": user_id,
						"message": "Heads up",
						"severity": "alert",
						"action_taken": False,
						"created_at": datetime.utcnow(),
					}
				],
				pocket_summaries=[
					PocketSummary(
						id="p-1",
						name="Emergency",
						balance=Decimal("20.00"),
						target=Decimal("100.00"),
						progress_percent=20.0,
					)
				],
				streak_summary={"current_streak": 2, "best_streak": 5, "last_save_date": None},
				recent_transactions=[],
			)

	dashboard_router_module.dashboard_service = _StubDashboardService()
	try:
		client = TestClient(app)
		res = client.get("/api/dashboard", params={"user_id": "u-1"})
	finally:
		dashboard_router_module.dashboard_service = original_service

	assert res.status_code == 200
	payload = res.json()
	assert "mascot" in payload
	assert "weekly_spend_total" in payload
	assert "weekly_budget_limit" in payload
	assert "weekly_budget_used_percent" in payload
	assert "category_breakdown" in payload
	assert "upcoming_bills" in payload
	assert "recent_alerts" in payload
	assert "pocket_summaries" in payload

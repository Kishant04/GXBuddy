from __future__ import annotations

from datetime import datetime
from decimal import Decimal

from app.core.database import TABLES, get_supabase_client
from app.core.utils import safe_percent_decimal, to_decimal, week_bounds
from app.schemas.contracts import BudgetProgress, BudgetUpsertRequest, ThresholdEvent


class BudgetService:
	"""Budget read/update service with weekly threshold detection."""

	def __init__(self, client=None) -> None:
		self.client = client or get_supabase_client()

	def _active_budgets(self, user_id: str, at: datetime | None = None) -> list[dict]:
		now = at or datetime.utcnow()
		result = (
			self.client.table(TABLES["budgets"])
			.select("*")
			.eq("userid", user_id)
			.lte("periodstart", now.isoformat())
			.gte("periodend", now.isoformat())
			.execute()
		)
		return result.data or []

	def _update_threshold_flag(self, budget_id: str, threshold: int) -> None:
		flag = {60: "alert60", 80: "alert80", 100: "alert100"}[threshold]
		self.client.table(TABLES["budgets"]).update({flag: True}).eq("id", budget_id).execute()

	def _to_budget_progress(self, budget: dict, spent: Decimal = Decimal("0")) -> BudgetProgress:
		weekly_limit = to_decimal(budget.get("weeklylimit", budget.get("weeklyLimit")))
		usage_pct = round(safe_percent_decimal(spent, weekly_limit), 2)
		return BudgetProgress(
			budget_id=budget["id"],
			category=budget.get("category"),
			weekly_limit=weekly_limit,
			spent_amount=spent.quantize(Decimal("0.01")),
			usage_percent=usage_pct,
		)

	def get_budget_progress(
		self,
		user_id: str,
		weekly_total: Decimal,
		category_totals: dict[str, Decimal],
	) -> tuple[list[BudgetProgress], list[ThresholdEvent]]:
		progress: list[BudgetProgress] = []
		events: list[ThresholdEvent] = []

		for budget in self._active_budgets(user_id):
			budget_id = budget["id"]
			category = budget.get("category")
			weekly_limit = to_decimal(budget.get("weeklylimit", budget.get("weeklyLimit")))
			scope = str(budget.get("scope", "overall")).strip().lower()

			if scope == "overall" or category is None:
				spent = weekly_total
			else:
				spent = category_totals.get(str(category).lower(), Decimal("0"))

			usage_pct = round(safe_percent_decimal(spent, weekly_limit), 2)
			progress.append(
				BudgetProgress(
					budget_id=budget_id,
					category=category,
					weekly_limit=weekly_limit,
					spent_amount=spent.quantize(Decimal("0.01")),
					usage_percent=usage_pct,
				)
			)

			threshold_flags = {
				60: bool(budget.get("alert60", False)),
				80: bool(budget.get("alert80", False)),
				100: bool(budget.get("alert100", False)),
			}
			for threshold in (60, 80, 100):
				if usage_pct >= threshold and not threshold_flags[threshold]:
					events.append(
						ThresholdEvent(
							budget_id=budget_id,
							threshold=threshold,
							usage_percent=usage_pct,
							message=f"Budget reached {threshold}% ({usage_pct:.0f}%) this week.",
						)
					)
					self._update_threshold_flag(budget_id, threshold)

		return progress, events

	def get_budget_snapshot(self, user_id: str) -> list[BudgetProgress]:
		start, end = week_bounds()
		tx_result = (
			self.client.table(TABLES["transactions"])
			.select("amount, category")
			.eq("userid", user_id)
			.gte("timestamp", start.isoformat())
			.lt("timestamp", end.isoformat())
			.execute()
		)
		rows = tx_result.data or []
		weekly_total = sum((to_decimal(r.get("amount")) for r in rows), Decimal("0"))
		category_totals: dict[str, Decimal] = {}
		for row in rows:
			key = str(row.get("category") or "uncategorized").lower()
			category_totals[key] = category_totals.get(key, Decimal("0")) + to_decimal(row.get("amount"))

		progress, _ = self.get_budget_progress(user_id, weekly_total, category_totals)
		return progress

	def upsert_budget(self, payload: BudgetUpsertRequest) -> BudgetProgress:
		period_start = payload.period_start
		period_end = payload.period_end
		if period_start is None or period_end is None:
			period_start, period_end = week_bounds()

		raw_scope = str(payload.scope).strip().lower()
		scope_aliases = {
			"overall": "overall",
			"category": "category",
		}
		scope = scope_aliases.get(raw_scope, raw_scope)
		category = payload.category.upper() if payload.category else None

		query = (
			self.client.table(TABLES["budgets"])
			.select("*")
			.eq("userid", payload.user_id)
			.eq("scope", scope)
		)
		if category is None:
			# Supabase/PostgREST needs IS NULL rather than eq(None).
			query = query.is_("category", "null")
		else:
			query = query.eq("category", category)

		existing = (
			query
			.lte("periodstart", period_start.isoformat())
			.gte("periodend", period_end.isoformat())
			.limit(1)
			.execute()
		)

		base_payload = {
			"userid": payload.user_id,
			"scope": scope,
			"category": category,
			# Decimal is not JSON-serializable in the Supabase client payload.
			"weeklylimit": str(payload.weekly_limit),
			"periodstart": period_start.isoformat(),
			"periodend": period_end.isoformat(),
			"alert60": payload.alert60,
			"alert80": payload.alert80,
			"alert100": payload.alert100,
		}

		if existing.data:
			updated = (
				self.client.table(TABLES["budgets"])
				.update(base_payload)
				.eq("id", existing.data[0]["id"])
				.execute()
			)
			row = updated.data[0]
		else:
			created = self.client.table(TABLES["budgets"]).insert(base_payload).execute()
			row = created.data[0]

		return self._to_budget_progress(row, spent=Decimal("0"))

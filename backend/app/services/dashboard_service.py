from __future__ import annotations

from datetime import datetime
from decimal import Decimal

from app.ai.mascot_engine import MascotInput, determine_mascot_state
from app.core.database import TABLES, get_supabase_client
from app.core.utils import safe_percent_decimal, to_decimal, to_float, week_bounds
from app.schemas.contracts import CategorySpend, DashboardResponse, StreakSummary, TransactionRecord
from app.schemas.dashboard import PocketSummary
from app.services.alert_service import AlertService
from app.services.bill_service import BillService
from app.services.budget_service import BudgetService


class DashboardService:
    """Aggregate home-screen data without placing business logic in routers."""

    def __init__(
        self,
        client=None,
        alert_service: AlertService | None = None,
        bill_service: BillService | None = None,
        budget_service: BudgetService | None = None,
    ) -> None:
        self.client = client or get_supabase_client()
        self.alert_service = alert_service or AlertService()
        self.bill_service = bill_service or BillService()
        self.budget_service = budget_service or BudgetService()

    def get_dashboard(self, user_id: str) -> DashboardResponse:
        start, end = week_bounds()

        # Full rows let us build both weekly totals and recent transactions.
        tx_result = (
            self.client.table(TABLES["transactions"])
            .select("*")
            .eq("userid", user_id)
            .gte("timestamp", start.isoformat())
            .lt("timestamp", end.isoformat())
            .order("timestamp", desc=True)
            .execute()
        )
        tx_rows = tx_result.data or []

        weekly_total = sum((to_decimal(row.get("amount")) for row in tx_rows), Decimal("0"))
        category_totals: dict[str, Decimal] = {}
        for row in tx_rows:
            key = str(row.get("category") or "uncategorized").lower()
            category_totals[key] = category_totals.get(key, Decimal("0")) + to_decimal(row.get("amount"))

        budget_progress, _ = self.budget_service.get_budget_progress(user_id, weekly_total, category_totals)
        weekly_budget_limit = sum((to_decimal(item.weekly_limit) for item in budget_progress), Decimal("0"))
        weekly_budget_used_percent = round(safe_percent_decimal(weekly_total, weekly_budget_limit), 2)

        alerts = self.alert_service.fetch_recent_alerts(user_id=user_id, limit=10)
        upcoming_bills = self.bill_service.get_upcoming_bills(user_id=user_id)
        bill_warnings = self.bill_service.get_bill_warnings(user_id=user_id)

        streak_result = self.client.table(TABLES["streaks"]).select("*").eq("userid", user_id).limit(1).execute()
        streak_row = (streak_result.data or [{}])[0]
        streak = StreakSummary(
            current_streak=int(streak_row.get("currentstreak", streak_row.get("currentStreak", 0))),
            best_streak=int(streak_row.get("beststreak", streak_row.get("bestStreak", 0))),
            last_save_date=streak_row.get("lastsavedate", streak_row.get("lastSaveDate")),
        )

        pockets_result = self.client.table(TABLES["pockets"]).select("*").eq("userid", user_id).execute()
        pocket_summaries: list[PocketSummary] = []
        for pocket in pockets_result.data or []:
            balance = to_decimal(pocket.get("balance", 0))
            target = to_decimal(pocket.get("target", 0))
            pocket_summaries.append(
                PocketSummary(
                    id=pocket["id"],
                    name=pocket.get("name", "Pocket"),
                    balance=balance.quantize(Decimal("0.01")),
                    target=target.quantize(Decimal("0.01")),
                    progress_percent=round(safe_percent_decimal(balance, target), 2),
                )
            )

        mascot = determine_mascot_state(
            MascotInput(
                weekly_percentage_used=weekly_budget_used_percent,
                savings_streak_days=streak.current_streak,
                upcoming_bill_due_soon=len(bill_warnings) > 0,
                weekly_alert_count=len(alerts),
                risk_score=min(100, weekly_budget_used_percent),
            )
        )

        category_breakdown = [
            CategorySpend(category=category, amount=amount.quantize(Decimal("0.01")))
            for category, amount in sorted(category_totals.items(), key=lambda x: x[1], reverse=True)
        ]

        recent_transactions: list[TransactionRecord] = []
        for row in tx_rows[:10]:
            ts = row.get("timestamp") or datetime.utcnow().isoformat()
            recent_transactions.append(
                TransactionRecord(
                    id=row["id"],
                    user_id=row.get("userid") or row.get("userId") or row.get("user_id", ""),
                    merchant=row.get("merchant", ""),
                    amount=to_decimal(row["amount"]),
                    category=str(row.get("category") or "uncategorized"),
                    source=str(row.get("source") or "MANUAL"),
                    status=str(row.get("status") or "POSTED"),
                    external_ref=row.get("externalref", row.get("externalRef")),
                    risk_score=to_float(row.get("riskscore")) if row.get("riskscore") is not None else (to_float(row.get("riskScore")) if row.get("riskScore") is not None else None),
                    category_confidence=to_float(row.get("categoryconfidence")) if row.get("categoryconfidence") is not None else (to_float(row.get("categoryConfidence")) if row.get("categoryConfidence") is not None else None),
                    is_bnpl=bool(row.get("isbnpl", row.get("isBnpl", False))),
                    alert_generated=bool(row.get("alertgenerated", row.get("alertGenerated", False))),
                    timestamp=datetime.fromisoformat(str(ts).replace("Z", "+00:00")).replace(tzinfo=None),
                )
            )

        return DashboardResponse(
            mascot=mascot,
            weekly_spend_total=weekly_total.quantize(Decimal("0.01")),
            weekly_budget_limit=weekly_budget_limit.quantize(Decimal("0.01")),
            weekly_budget_used_percent=weekly_budget_used_percent,
            category_breakdown=category_breakdown,
            upcoming_bills=upcoming_bills,
            pocket_summaries=pocket_summaries,
            recent_alerts=alerts,
            streak_summary=streak,
            recent_transactions=recent_transactions,
        )

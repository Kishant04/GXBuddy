from __future__ import annotations

from datetime import datetime
from decimal import Decimal

from app.ai.mascot_engine import MascotInput, determine_mascot_state
from app.ai.nudge_generator import NudgeInput, generate_nudge
from app.ai.risk_scoring import RiskInput, calculate_risk_score
from app.ai.spending_classifier import ClassificationInput, classify_spending
from app.core.database import TABLES, get_supabase_client
from app.core.utils import is_late_night, safe_percent_decimal, to_decimal, to_float, week_bounds
from app.schemas.contracts import (
    AlertSeverity,
    TransactionCreateRequest,
    TransactionProcessResponse,
    TransactionRecord,
    TransactionsListResponse,
    WebSocketEvent,
)
from app.services.alert_service import AlertService
from app.services.bill_service import BillService
from app.services.budget_service import BudgetService
from app.services.notification_service import NotificationService


class TransactionService:
    """Orchestrate the full Feature 1 transaction reaction loop."""

    def __init__(
        self,
        client=None,
        alert_service: AlertService | None = None,
        bill_service: BillService | None = None,
        budget_service: BudgetService | None = None,
        notification_service: NotificationService | None = None,
    ) -> None:
        self.client = client or get_supabase_client()
        self.alert_service = alert_service or AlertService()
        self.bill_service = bill_service or BillService()
        self.budget_service = budget_service or BudgetService()
        self.notification_service = notification_service or NotificationService()

    def _to_transaction_record(self, row: dict) -> TransactionRecord:
        ts = row.get("timestamp") or datetime.utcnow().isoformat()
        return TransactionRecord(
            id=row["id"],
            user_id=row.get("userid") or row.get("userId") or row.get("user_id", ""),
            amount=to_decimal(row["amount"]),
            merchant=row.get("merchant", ""),
            category=str(row.get("category") or "uncategorized"),
            source=str(row.get("source") or "MANUAL"),
            status=str(row.get("status") or "POSTED"),
            external_ref=row.get("externalref", row.get("externalRef")),
            risk_score=(
                to_float(row["riskscore"])
                if row.get("riskscore") is not None
                else (to_float(row["riskScore"]) if row.get("riskScore") is not None else None)
            ),
            category_confidence=(
                to_float(row["categoryconfidence"])
                if row.get("categoryconfidence") is not None
                else (
                    to_float(row["categoryConfidence"])
                    if row.get("categoryConfidence") is not None
                    else None
                )
            ),
            is_bnpl=bool(row.get("isbnpl", row.get("isBnpl", False))),
            alert_generated=bool(row.get("alertgenerated", row.get("alertGenerated", False))),
            timestamp=datetime.fromisoformat(str(ts).replace("Z", "+00:00")).replace(tzinfo=None),
        )

    def list_transactions(self, user_id: str, limit: int = 30) -> TransactionsListResponse:
        result = (
            self.client.table(TABLES["transactions"])
            .select("*")
            .eq("userid", user_id)
            .order("timestamp", desc=True)
            .limit(limit)
            .execute()
        )
        items = [self._to_transaction_record(row) for row in (result.data or [])]
        return TransactionsListResponse(items=items)

    def _category_totals(self, rows: list[dict]) -> dict[str, Decimal]:
        category_totals: dict[str, Decimal] = {}
        for row in rows:
            key = str(row.get("category") or "uncategorized").lower()
            category_totals[key] = (
                category_totals.get(key, Decimal("0")) + to_decimal(row.get("amount"))
            )
        return category_totals

    async def _emit_events(self, events: list[WebSocketEvent]) -> None:
        for event in events:
            await self.notification_service.emit_event(event)

    async def process_transaction(
        self, payload: TransactionCreateRequest
    ) -> TransactionProcessResponse:
        timestamp = payload.timestamp or datetime.utcnow()
        amount = to_decimal(payload.amount)
        print(f"[TX] Processing: {payload.merchant}, RM{amount}, User={payload.user_id}")

        insert_payload = {
            "userid": payload.user_id,
            "amount": str(amount),
            "category": (payload.category.value if payload.category else "OTHER"),
            "merchant": payload.merchant,
            "source": payload.source.value,
            "externalref": payload.external_ref,
            "status": payload.status.value,
            "isbnpl": payload.is_bnpl,
            "timestamp": timestamp.isoformat(),
        }
        inserted = self.client.table(TABLES["transactions"]).insert(insert_payload).execute()
        if not inserted.data:
            print("[TX] Failed to insert into Supabase")
            raise RuntimeError("Failed to create transaction")
        transaction_row = inserted.data[0]
        print(f"[TX] Created ID: {transaction_row['id']} at {transaction_row['timestamp']}")

        start, end = week_bounds(timestamp)
        print(f"[TX] Aggregating week bounds: {start.isoformat()} to {end.isoformat()}")
        tx_result = (
            self.client.table(TABLES["transactions"])
            .select("amount, category, merchant, timestamp, status")
            .eq("userid", payload.user_id)
            .gte("timestamp", start.isoformat())
            .lte("timestamp", end.isoformat())
            .execute()
        )
        weekly_rows = tx_result.data or []
        print(f"[TX] Found {len(weekly_rows)} transactions for aggregation")

        merchant_rows = [
            row
            for row in weekly_rows
            if str(row.get("merchant", "")).lower().strip()
            == payload.merchant.lower().strip()
        ]
        historical_average = Decimal("0")
        if merchant_rows:
            historical_average = sum(
                to_decimal(row.get("amount")) for row in merchant_rows
            ) / Decimal(len(merchant_rows))

        weekly_frequency = max(0, len(merchant_rows))

        classification = classify_spending(
            ClassificationInput(
                merchant=payload.merchant,
                category=payload.category.value if payload.category else None,
                amount=float(amount),
                timestamp=timestamp,
                source=payload.source.value,
                historical_average=float(historical_average),
                weekly_frequency=weekly_frequency,
            )
        )

        # Filter for spend total (Exclude SALARY, include only POSTED)
        spend_rows = [
            row for row in weekly_rows 
            if str(row.get("category") or "").upper() != "SALARY"
            and str(row.get("status") or "POSTED").upper() == "POSTED"
        ]

        weekly_total = sum(to_decimal(row.get("amount")) for row in spend_rows)
        category_totals = self._category_totals(spend_rows)

        budget_progress, threshold_events = self.budget_service.get_budget_progress(
            user_id=payload.user_id,
            weekly_total=weekly_total,
            category_totals=category_totals,
        )
        
        # Priority: use the overall budget limit if it exists
        overall_budget = next((item for item in budget_progress if item.category is None), None)
        if overall_budget:
            weekly_budget_limit = to_decimal(overall_budget.weekly_limit)
        else:
            weekly_budget_limit = sum((to_decimal(item.weekly_limit) for item in budget_progress), Decimal("0"))
            
        weekly_pct = safe_percent_decimal(weekly_total, weekly_budget_limit)
        category_key = (
            payload.category.value if payload.category else classification.primary.value
        ).lower()
        cat_spend = category_totals.get(category_key, Decimal("0"))
        overspend_ratio = float(cat_spend / historical_average) if historical_average > 0 else 1.0

        upcoming_bills = self.bill_service.get_upcoming_bills(payload.user_id, days_ahead=3)
        bill_warnings = self.bill_service.get_bill_warnings(payload.user_id)
        risk = calculate_risk_score(
            RiskInput(
                weekly_spend_so_far=float(weekly_total),
                budget_limit=float(weekly_budget_limit),
                category_overspend_ratio=overspend_ratio,
                late_night_spending=is_late_night(timestamp),
                upcoming_bills_total=float(
                    sum((to_decimal(b.amount) for b in upcoming_bills), Decimal("0"))
                ),
                spending_frequency=weekly_frequency,
                historical_average=float(historical_average),
                amount=float(amount),
                time_of_day=timestamp.hour,
            )
        )

        cat_upper = (payload.category.value if payload.category else classification.primary.value).upper()
        is_savings = cat_upper == "SAVINGS"

        alerts_this_week = self.alert_service.fetch_recent_alerts(payload.user_id, limit=50)
        mascot = determine_mascot_state(
            MascotInput(
                weekly_percentage_used=weekly_pct,
                savings_streak_days=0,
                upcoming_bill_due_soon=any(1 <= b.days_remaining <= 3 for b in upcoming_bills),
                weekly_alert_count=len(alerts_this_week),
                risk_score=risk.score,
                is_savings_context=is_savings,
            )
        )

        nudge = generate_nudge(
            NudgeInput(
                category=classification.primary.value,
                amount=float(amount),
                budget_used_percent=weekly_pct,
                average_spend=float(historical_average),
                time_of_day=timestamp.hour,
                upcoming_bills_count=len(upcoming_bills),
                risk_score=risk.score,
                weekly_frequency=weekly_frequency,
            )
        )

        created_alerts = []
        for event in threshold_events:
            severity = AlertSeverity.ALERT if event.threshold < 100 else AlertSeverity.PANICKED
            alert = self.alert_service.create_alert(payload.user_id, event.message, severity)
            if alert:
                created_alerts.append(alert)
                # Emit to WebSocket/External
                await self.notification_service.emit_alert(payload.user_id, alert)

        if nudge and nudge.severity in {
            AlertSeverity.ALERT,
            AlertSeverity.PANICKED,
            AlertSeverity.EMERGENCY,
        }:
            alert = self.alert_service.create_alert(
                payload.user_id, nudge.message, nudge.severity
            )
            if alert:
                created_alerts.append(alert)
                # Emit to WebSocket/External
                await self.notification_service.emit_alert(payload.user_id, alert)

        update_payload = {
            "category": (
                payload.category.value
                if payload.category
                else classification.primary.value.upper()
            ),
            "riskscore": risk.score,
            "categoryconfidence": classification.confidence,
            "alertgenerated": len(created_alerts) > 0,
        }
        updated = (
            self.client.table(TABLES["transactions"])
            .update(update_payload)
            .eq("id", transaction_row["id"])
            .execute()
        )
        transaction = self._to_transaction_record(
            updated.data[0] if updated.data else transaction_row
        )

        websocket_events = [
            self.notification_service.build_transaction_processed_event(
                user_id=payload.user_id,
                transaction_id=transaction.id,
                risk_score=risk.score,
            ),
            self.notification_service.build_mascot_state_event(
                user_id=payload.user_id, mascot=mascot
            ),
        ]
        websocket_events.extend(
            [
                self.notification_service.build_alert_event(
                    user_id=payload.user_id, alert=alert
                )
                for alert in created_alerts
            ]
        )
        websocket_events.extend(
            [
                self.notification_service.build_bill_warning_event(
                    user_id=payload.user_id, warning=warning
                )
                for warning in bill_warnings
            ]
        )

        await self._emit_events(websocket_events)

        return TransactionProcessResponse(
            transaction=transaction,
            classification=classification.primary.value,
            risk_score=risk.score,
            mascot=mascot,
            alert=nudge,
            classification_details=classification,
            risk_details=risk,
            alerts=created_alerts,
            budget_progress=budget_progress,
            threshold_events=threshold_events,
            websocket_events=websocket_events,
        )
from __future__ import annotations

from datetime import datetime, timedelta

from app.core.database import TABLES, get_supabase_client
from app.core.utils import days_until, to_decimal
from app.schemas.contracts import AlertSeverity, BillWarning, UpcomingBill


class BillService:
	"""Bill reminder service for upcoming bill retrieval and precaution warnings."""

	def __init__(self, client=None) -> None:
		self.client = client or get_supabase_client()

	def get_upcoming_bills(self, user_id: str, days_ahead: int = 7) -> list[UpcomingBill]:
		now = datetime.utcnow()
		horizon = now + timedelta(days=days_ahead)
		result = (
			self.client.table(TABLES["bill_reminders"])
			.select("*")
			.eq("userid", user_id)
			.eq("ispaid", False)
			.gte("duedate", now.isoformat())
			.lte("duedate", horizon.isoformat())
			.order("duedate")
			.execute()
		)

		bills: list[UpcomingBill] = []
		for row in result.data or []:
			due_raw = row.get("duedate", row.get("dueDate"))
			due = datetime.fromisoformat(str(due_raw).replace("Z", "+00:00")).replace(tzinfo=None)
			bills.append(
				UpcomingBill(
					id=row["id"],
					name=row["name"],
					amount=to_decimal(row["amount"]),
					due_date=due,
					days_remaining=days_until(due),
					is_paid=bool(row.get("ispaid", row.get("isPaid", False))),
				)
			)
		return bills

	def get_bill_warnings(self, user_id: str) -> list[BillWarning]:
		warnings: list[BillWarning] = []
		for bill in self.get_upcoming_bills(user_id=user_id, days_ahead=3):
			if 1 <= bill.days_remaining <= 3:
				warnings.append(
					BillWarning(
						bill_id=bill.id,
						message=f"Your {bill.name} bill is due in {bill.days_remaining} day(s), spend wisely.",
						severity=AlertSeverity.ALERT,
						days_remaining=bill.days_remaining,
					)
				)
		return warnings

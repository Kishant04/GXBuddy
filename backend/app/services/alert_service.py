from __future__ import annotations

from datetime import datetime, timedelta

from app.core.database import TABLES, get_supabase_client
from app.schemas.contracts import AlertItem, AlertSeverity


class AlertService:
	"""Alert persistence service with duplicate-spam protection."""

	def __init__(self, client=None) -> None:
		self.client = client or get_supabase_client()

	def _to_alert_item(self, row: dict) -> AlertItem:
		created_at = row.get("createdat") or row.get("createdAt") or row.get("created_at") or datetime.utcnow().isoformat()
		return AlertItem(
			id=row["id"],
			user_id=row.get("userid") or row.get("userId") or row.get("user_id"),
			message=row["message"],
			severity=AlertSeverity((row.get("severity") or "alert").lower()),
			action_taken=bool(row.get("actiontaken", row.get("actionTaken", row.get("action_taken", False)))),
			created_at=datetime.fromisoformat(str(created_at).replace("Z", "+00:00")).replace(tzinfo=None),
		)

	def create_alert(self, user_id: str, message: str, severity: AlertSeverity) -> AlertItem | None:
		existing = (
			self.client.table(TABLES["alerts"])
			.select("*")
			.eq("userid", user_id)
			.eq("message", message)
			.order("createdat", desc=True)
			.limit(1)
			.execute()
		)
		rows = existing.data or []
		if rows:
			latest = self._to_alert_item(rows[0])
			if latest.created_at >= datetime.utcnow() - timedelta(minutes=30):
				return None

		payload = {
			"userid": user_id,
			"message": message,
			"severity": severity.value,
			"actiontaken": False,
		}
		inserted = self.client.table(TABLES["alerts"]).insert(payload).execute()
		if not inserted.data:
			return None
		return self._to_alert_item(inserted.data[0])

	def mark_actioned(self, alert_id: str) -> AlertItem | None:
		updated = (
			self.client.table(TABLES["alerts"])
			.update({"actiontaken": True})
			.eq("id", alert_id)
			.execute()
		)
		if not updated.data:
			return None
		return self._to_alert_item(updated.data[0])

	def fetch_recent_alerts(self, user_id: str, severity: str | None = None, limit: int = 20) -> list[AlertItem]:
		query = self.client.table(TABLES["alerts"]).select("*").eq("userid", user_id).order("createdat", desc=True).limit(limit)
		if severity:
			query = query.eq("severity", severity)
		result = query.execute()
		return [self._to_alert_item(row) for row in (result.data or [])]

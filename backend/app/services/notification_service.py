from __future__ import annotations

"""Notification service for websocket event preparation and delivery."""

from app.schemas.contracts import AlertItem, BillWarning, MascotStatus, WebSocketEvent, WebSocketEventType
from app.core.websocket_manager import manager


class NotificationService:
    """Prepare and emit websocket events without leaking transport details to routers."""

    async def emit_event(self, event: WebSocketEvent) -> None:
        await manager.send_to_user(
            event.user_id,
            event.model_dump(mode="json", by_alias=True),
        )

    def build_alert_event(self, user_id: str, alert: AlertItem) -> WebSocketEvent:
        return WebSocketEvent(
            event=WebSocketEventType.ALERT,
            user_id=user_id,
            payload=alert.model_dump(mode="json"),
        )

    def build_mascot_state_event(self, user_id: str, mascot: MascotStatus) -> WebSocketEvent:
        return WebSocketEvent(
            event=WebSocketEventType.MASCOT_STATE,
            user_id=user_id,
            payload=mascot.model_dump(mode="json"),
        )

    def build_bill_warning_event(self, user_id: str, warning: BillWarning) -> WebSocketEvent:
        return WebSocketEvent(
            event=WebSocketEventType.BILL_WARNING,
            user_id=user_id,
            payload=warning.model_dump(mode="json"),
        )

    def build_transaction_processed_event(self, user_id: str, transaction_id: str, risk_score: float) -> WebSocketEvent:
        return WebSocketEvent(
            event=WebSocketEventType.TRANSACTION_PROCESSED,
            user_id=user_id,
            payload={"transaction_id": transaction_id, "risk_score": risk_score},
        )

    async def emit_alert(self, user_id: str, alert: AlertItem) -> None:
        await self.emit_event(self.build_alert_event(user_id=user_id, alert=alert))

    async def emit_mascot_state(self, user_id: str, mascot: MascotStatus) -> None:
        await self.emit_event(self.build_mascot_state_event(user_id=user_id, mascot=mascot))

    async def emit_bill_warning(self, user_id: str, warning: BillWarning) -> None:
        await self.emit_event(self.build_bill_warning_event(user_id=user_id, warning=warning))

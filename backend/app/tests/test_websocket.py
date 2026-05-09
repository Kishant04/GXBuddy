from __future__ import annotations

import asyncio

from starlette.websockets import WebSocketState

from app.core.websocket_manager import ConnectionManager


class _FakeWebSocket:
	def __init__(self, connected: bool = True) -> None:
		self.accepted = False
		self.messages: list[dict] = []
		self.client_state = WebSocketState.CONNECTED if connected else WebSocketState.DISCONNECTED

	async def accept(self) -> None:
		self.accepted = True

	async def send_json(self, payload: dict) -> None:
		if self.client_state != WebSocketState.CONNECTED:
			raise RuntimeError("socket is not connected")
		self.messages.append(payload)


def test_connect_send_disconnect_cycle() -> None:
	manager = ConnectionManager()
	ws = _FakeWebSocket()

	asyncio.run(manager.connect("u-1", ws))
	assert ws.accepted is True
	assert manager.is_connected("u-1") is True

	asyncio.run(manager.send_to_user("u-1", {"type": "alert", "data": {"message": "heads up"}}))
	assert ws.messages and ws.messages[0]["type"] == "alert"

	manager.disconnect("u-1", ws)
	assert manager.is_connected("u-1") is False


def test_send_to_missing_user_is_safe() -> None:
	manager = ConnectionManager()
	asyncio.run(manager.send_to_user("missing-user", {"type": "alert", "data": {}}))
	assert manager.is_connected("missing-user") is False


def test_broadcast_skips_stale_socket_and_keeps_live_socket() -> None:
	manager = ConnectionManager()
	live_ws = _FakeWebSocket(connected=True)
	stale_ws = _FakeWebSocket(connected=False)

	asyncio.run(manager.connect("u-live", live_ws))
	# Insert stale socket manually to simulate abrupt client-side drop.
	manager._connections["u-stale"].add(stale_ws)

	asyncio.run(manager.broadcast({"type": "bill_warning", "data": {"days": 2}}))

	assert live_ws.messages and live_ws.messages[0]["type"] == "bill_warning"
	assert manager.is_connected("u-stale") is False

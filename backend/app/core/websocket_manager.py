from __future__ import annotations

import logging
from collections import defaultdict

from fastapi import WebSocket
from starlette.websockets import WebSocketState

logger = logging.getLogger(__name__)


class ConnectionManager:
    """
    Per-user WebSocket room manager.

    Each user_id maps to a set of WebSocket connections (supports
    multiple tabs / devices). Safe to call send_to_user when the user
    is not connected — the message is silently dropped.

    Designed for hackathon MVP: no auth at the transport layer, but the
    user_id parameter on connect() is the insertion point for future
    token validation.
    """

    def __init__(self) -> None:
        # user_id → set of active WebSocket connections
        self._connections: dict[str, set[WebSocket]] = defaultdict(set)

    # ------------------------------------------------------------------
    # Connection lifecycle
    # ------------------------------------------------------------------

    async def connect(self, user_id: str, websocket: WebSocket) -> None:
        """Accept and register a new connection for user_id."""
        await websocket.accept()
        self._connections[user_id].add(websocket)
        logger.debug("WS connected: user=%s total_sockets=%d", user_id, len(self._connections[user_id]))

    def disconnect(self, user_id: str, websocket: WebSocket) -> None:
        """Remove a specific socket for user_id. Cleans up empty rooms."""
        if user_id not in self._connections:
            return
        self._connections[user_id].discard(websocket)
        if not self._connections[user_id]:
            del self._connections[user_id]
        logger.debug("WS disconnected: user=%s", user_id)

    def is_connected(self, user_id: str) -> bool:
        """Return True if the user has at least one live connection."""
        return bool(self._connections.get(user_id))

    # ------------------------------------------------------------------
    # Sending
    # ------------------------------------------------------------------

    async def send_to_user(self, user_id: str, payload: dict) -> None:
        """
        Send a JSON payload to all sockets belonging to user_id.
        Silently skips if the user is not connected.
        Stale / half-closed sockets are cleaned up automatically.
        """
        stale: list[WebSocket] = []
        for ws in list(self._connections.get(user_id, set())):
            try:
                if ws.client_state == WebSocketState.CONNECTED:
                    await ws.send_json(payload)
                else:
                    stale.append(ws)
            except Exception:
                logger.warning("WS send failed for user=%s, removing stale socket.", user_id)
                stale.append(ws)

        for ws in stale:
            self.disconnect(user_id, ws)

    async def broadcast(self, payload: dict) -> None:
        """
        Broadcast a payload to every currently-connected user.
        Useful for system-wide announcements (maintenance, feature flags).
        """
        for user_id in list(self._connections.keys()):
            await self.send_to_user(user_id, payload)

    # ------------------------------------------------------------------
    # Backwards-compat alias kept for existing notification_service calls
    # ------------------------------------------------------------------

    async def broadcast_to_user_room(self, user_id: str, payload: dict) -> None:
        await self.send_to_user(user_id, payload)
manager = ConnectionManager()

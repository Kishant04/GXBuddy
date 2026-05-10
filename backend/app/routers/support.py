from __future__ import annotations

import os

from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.core.websocket_manager import manager
from app.routers.auth import verify_token

router = APIRouter()

_DEBUG = os.getenv("DEBUG", "false").lower() == "true"


async def _resolve_ws_user(token: str | None, user_id: str | None) -> dict | None:
    """Resolve user from JWT token or dev bypass (DEBUG mode only)."""
    # Dev bypass: accept plain user_id when DEBUG=true
    if _DEBUG and user_id:
        return {"id": user_id, "email": None}
    if token:
        try:
            return verify_token(token)
        except Exception:
            pass
    return None


@router.websocket("/ws")
async def websocket_endpoint(
    websocket: WebSocket,
    token: str | None = None,
    user_id: str | None = None,
):
    user = await _resolve_ws_user(token, user_id)
    if not user:
        await websocket.close(code=1008)
        return

    await manager.connect(user["id"], websocket)
    try:
        while True:
            await websocket.receive_text()  # keep-alive; client sends pings
    except WebSocketDisconnect:
        manager.disconnect(user["id"], websocket)
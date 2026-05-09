from __future__ import annotations

from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.core.websocket_manager import manager
from app.routers.auth import verify_token

router = APIRouter()


async def get_current_user_ws(token: str) -> dict | None:
    """Validate a token for WebSocket connections (no Header dependency available)."""
    try:
        return verify_token(token)
    except Exception:
        return None


@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket, token: str):
    user = await get_current_user_ws(token)
    if not user:
        await websocket.close(code=1008)
        return

    await manager.connect(user["id"], websocket)
    try:
        while True:
            await websocket.receive_text()  # keep-alive; client sends pings
    except WebSocketDisconnect:
        manager.disconnect(user["id"], websocket)
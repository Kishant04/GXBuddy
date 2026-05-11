from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Header
from pydantic import BaseModel
from typing import Optional

from app.routers.auth import get_current_user
from app.core.config import settings
from seed import seed

router = APIRouter(prefix="/api/demo", tags=["demo"])

class DemoResetRequest(BaseModel):
    user_id: Optional[str] = None

@router.post("/reset")
async def reset_demo(
    payload: DemoResetRequest, 
    authorization: Optional[str] = Header(None),
    x_demo_reset_key: Optional[str] = Header(None)
):
    """
    Resets the user's data to the default demo state.
    Only enabled if DEMO_RESET_ENABLED is true.
    Supports either a valid Bearer JWT or a local X-Demo-Reset-Key.
    """
    if not settings.DEMO_RESET_ENABLED:
        raise HTTPException(403, detail="Demo reset is disabled in this environment.")

    target_user_id = payload.user_id
    authenticated_user = None

    # 1. Try Bearer JWT if provided
    if authorization:
        try:
            authenticated_user = await get_current_user(authorization=authorization)
        except HTTPException:
            # If token is invalid/expired, we only continue if the reset key is present
            if not x_demo_reset_key:
                raise

    # 2. Check X-Demo-Reset-Key if JWT failed or was missing
    if not authenticated_user:
        if not x_demo_reset_key or x_demo_reset_key != settings.DEMO_RESET_KEY:
            raise HTTPException(
                status_code=401, 
                detail="Authentication failed. Provide a valid token or demo reset key."
            )

    # 3. Resolve target_user_id
    # If no ID in payload, use authenticated user. 
    # If using reset key without payload ID, we might need a default or error.
    if not target_user_id:
        if authenticated_user:
            target_user_id = authenticated_user["id"]
        else:
            # Bypass mode requires an explicit user_id in payload
            raise HTTPException(status_code=400, detail="user_id is required when using demo reset key.")
    
    # Validation: Only allow resetting own data or specific demo user
    # (Leeway allowed for hackathon as requested)

    try:
        print(f"[DEMO] Resetting data for user: {target_user_id}")
        summary = seed(target_user_id)
        return {
            "ok": True,
            "message": "Demo data reset successful",
            "user_id": target_user_id,
            "summary": summary
        }
    except Exception as e:
        print(f"[DEMO] Reset failed: {e}")
        raise HTTPException(500, detail=f"Reset failed: {str(e)}")


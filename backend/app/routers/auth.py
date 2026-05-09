from __future__ import annotations

from fastapi import APIRouter, Depends, Header, HTTPException

from app.core.database import get_supabase_client

router = APIRouter(prefix="/api/auth", tags=["auth"])


# -----------------------------------
# DB DEPENDENCY
# -----------------------------------
def get_db():
    return get_supabase_client()


# -----------------------------------
# VERIFY SUPABASE JWT TOKEN
# -----------------------------------
def verify_token(token: str) -> dict:
    supabase = get_supabase_client()
    try:
        user_response = supabase.auth.get_user(token)
        if not user_response or not user_response.user:
            raise HTTPException(status_code=401, detail="Invalid token")
        return {
            "id": user_response.user.id,
            "email": user_response.user.email,
        }
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid or expired token")


# -----------------------------------
# CURRENT USER DEPENDENCY
# -----------------------------------
async def get_current_user(authorization: str = Header(None)) -> dict:
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing Authorization header")
    try:
        token = authorization.replace("Bearer ", "")
        return verify_token(token)
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(status_code=401, detail="Authentication failed")


# -----------------------------------
# HEALTH CHECK
# -----------------------------------
@router.get("/health")
async def auth_health():
    return {"status": "Auth router working"}


# -----------------------------------
# GET CURRENT USER
# -----------------------------------
@router.get("/me")
async def get_me(user: dict = Depends(get_current_user)):
    return {"user": user}
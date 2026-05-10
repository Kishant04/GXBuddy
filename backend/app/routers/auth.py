from __future__ import annotations

import os

from fastapi import APIRouter, Depends, Header, HTTPException
from pydantic import BaseModel

from app.core.database import get_supabase_client

router = APIRouter(prefix="/api/auth", tags=["auth"])

_DEBUG = os.getenv("DEBUG", "false").lower() == "true"


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
async def get_current_user(
    authorization: str = Header(None),
    x_dev_user_id: str = Header(None),
) -> dict:
    # Dev bypass: accepted only when DEBUG=true in .env
    if _DEBUG and x_dev_user_id:
        return {"id": x_dev_user_id, "email": None}

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
# LOGIN (email + password → JWT)
# -----------------------------------
class LoginRequest(BaseModel):
    email: str
    password: str


@router.post("/login")
async def login(body: LoginRequest):
    supabase = get_supabase_client()
    try:
        res = supabase.auth.sign_in_with_password(
            {"email": body.email, "password": body.password}
        )
        return {
            "access_token": res.session.access_token,
            "user_id": res.user.id,
            "email": res.user.email,
        }
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid email or password")


# -----------------------------------
# GET CURRENT USER
# -----------------------------------
@router.get("/me")
async def get_me(user: dict = Depends(get_current_user)):
    return {"user": user}
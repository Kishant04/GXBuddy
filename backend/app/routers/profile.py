from __future__ import annotations

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional

from app.core.database import get_supabase_client
from app.routers.auth import get_current_user

router = APIRouter(prefix="/api/profile", tags=["profile"])


class ProfileResponse(BaseModel):
    id: str
    email: Optional[str] = None
    name: str = "User"
    monthly_income: float = 0.0
    level: int = 1
    streak_days: int = 0
    squad_id: Optional[str] = None
    push_enabled: bool = True
    whatsapp_enabled: bool = False
    telegram_enabled: bool = False
    anonymous_squad: bool = False
    hide_balances: bool = True


class ProfileUpdate(BaseModel):
    name: Optional[str] = None
    monthly_income: Optional[float] = None
    push_enabled: Optional[bool] = None
    anonymous_squad: Optional[bool] = None
    hide_balances: Optional[bool] = None


def _build_profile(user_id: str, email: str | None = None) -> ProfileResponse:
    db = get_supabase_client()

    # Try to load user record
    user_row: dict = {}
    try:
        res = db.table("User").select("*").eq("id", user_id).limit(1).execute()
        if res.data:
            user_row = res.data[0]
    except Exception:
        pass

    # Try to load streak
    streak_days = 0
    try:
        s = db.table("Streak").select("currentstreak").eq("userid", user_id).limit(1).execute()
        if s.data:
            streak_days = int(s.data[0].get("currentstreak", 0))
    except Exception:
        pass

    # Try to find squad membership
    squad_id = None
    try:
        sq = db.table("SquadMember").select("squadid").eq("userid", user_id).limit(1).execute()
        if sq.data:
            squad_id = sq.data[0].get("squadid")
    except Exception:
        pass

    return ProfileResponse(
        id=user_id,
        email=email or user_row.get("email"),
        name=user_row.get("name") or "User",
        monthly_income=float(user_row.get("monthlyincome") or user_row.get("salary_threshold") or 0),
        level=int(user_row.get("level", 1)),
        streak_days=streak_days,
        squad_id=squad_id,
        push_enabled=bool(user_row.get("push_enabled", True)),
        whatsapp_enabled=False,   # on hold
        telegram_enabled=False,    # on hold
        anonymous_squad=bool(user_row.get("anonymous_squad", False)),
        hide_balances=bool(user_row.get("hide_balances", True)),
    )


@router.get("", response_model=ProfileResponse)
async def get_profile(user=Depends(get_current_user)):
    return _build_profile(user["id"], user.get("email"))


@router.patch("", response_model=ProfileResponse)
async def update_profile(payload: ProfileUpdate, user=Depends(get_current_user)):
    db = get_supabase_client()
    update: dict = {}

    if payload.name is not None:
        update["name"] = payload.name
    if payload.monthly_income is not None:
        update["monthlyincome"] = payload.monthly_income
        update["salary_threshold"] = payload.monthly_income * 0.5  # autopilot threshold
    if payload.push_enabled is not None:
        update["push_enabled"] = payload.push_enabled
    if payload.anonymous_squad is not None:
        update["anonymous_squad"] = payload.anonymous_squad
    if payload.hide_balances is not None:
        update["hide_balances"] = payload.hide_balances

    if update:
        try:
            exists = db.table("User").select("id").eq("id", user["id"]).limit(1).execute()
            if exists.data:
                db.table("User").update(update).eq("id", user["id"]).execute()
            else:
                update["id"] = user["id"]
                db.table("User").insert(update).execute()
        except Exception:
            pass

    return _build_profile(user["id"], user.get("email"))

from __future__ import annotations

from fastapi import APIRouter, Depends, Header, HTTPException
from pydantic import BaseModel
from typing import Optional

from app.core.database import get_supabase_client
from app.routers.auth import get_current_user

router = APIRouter(prefix="/api/profile", tags=["profile"])


class ProfileResponse(BaseModel):
    user_id: str
    email: Optional[str] = None
    display_name: str = "User"
    short_name: str = "User"
    monthly_income: float = 0.0
    salary_threshold: float = 0.0
    current_streak: int = 0
    best_streak: int = 0
    level_label: str = "Level 1 saver"
    squad_id: Optional[str] = None
    push_notifications_enabled: bool = True
    whatsapp_alerts_enabled: bool = False
    telegram_alerts_enabled: bool = False
    anonymous_squad_progress: bool = False
    hide_exact_balances: bool = True
    card_frozen: bool = False
    spending_limit: float = 0.0


class ProfileUpdate(BaseModel):
    display_name: Optional[str] = None
    monthly_income: Optional[float] = None
    push_notifications_enabled: Optional[bool] = None
    whatsapp_alerts_enabled: Optional[bool] = None
    telegram_alerts_enabled: Optional[bool] = None
    anonymous_squad_progress: Optional[bool] = None
    hide_exact_balances: Optional[bool] = None
    card_frozen: Optional[bool] = None
    spending_limit: Optional[float] = None


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
    current_streak = 0
    best_streak = 0
    try:
        s = db.table("Streak").select("*").eq("userid", user_id).limit(1).execute()
        if s.data:
            current_streak = int(s.data[0].get("currentstreak", 0))
            best_streak = int(s.data[0].get("beststreak", current_streak))
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

    name = user_row.get("name") or user_row.get("display_name") or "User"
    short_name = name.split(" ")[0]

    return ProfileResponse(
        user_id=user_id,
        email=email or user_row.get("email"),
        display_name=name,
        short_name=short_name,
        monthly_income=float(user_row.get("monthlyincome") or user_row.get("monthly_income") or 0),
        salary_threshold=float(user_row.get("salarythreshold") or user_row.get("salary_threshold") or 0),
        current_streak=current_streak,
        best_streak=best_streak,
        level_label=f"Level {user_row.get('level', 1)} saver",
        squad_id=squad_id,
        push_notifications_enabled=bool(user_row.get("push_notifications_enabled", user_row.get("pushenabled", True))),
        whatsapp_alerts_enabled=bool(user_row.get("whatsapp_alerts_enabled", user_row.get("whatsappenabled", False))),
        telegram_alerts_enabled=bool(user_row.get("telegram_alerts_enabled", user_row.get("telegramenabled", False))),
        anonymous_squad_progress=bool(user_row.get("anonymous_squad_progress", user_row.get("anonymoussquad", False))),
        hide_exact_balances=bool(user_row.get("hide_exact_balances", user_row.get("hidebalances", True))),
        card_frozen=bool(user_row.get("card_frozen", user_row.get("cardfrozen", False))),
        spending_limit=float(user_row.get("spending_limit", user_row.get("weeklyspendinglimit", 0))),
    )


@router.get("", response_model=ProfileResponse)
async def get_profile(
    user_id: Optional[str] = None,
    authorization: Optional[str] = Header(None),
    x_dev_user_id: Optional[str] = Header(None),
):
    target_id = user_id
    email = None

    if not target_id:
        # Fallback to current user if no user_id query param
        user = await get_current_user(authorization=authorization, x_dev_user_id=x_dev_user_id)
        target_id = user["id"]
        email = user.get("email")

    return _build_profile(target_id, email)


@router.patch("", response_model=ProfileResponse)
async def update_profile(payload: ProfileUpdate, user=Depends(get_current_user)):
    db = get_supabase_client()
    update: dict = {}

    if payload.display_name is not None:
        update["name"] = payload.display_name
    if payload.monthly_income is not None:
        update["monthlyincome"] = payload.monthly_income
        # Update salary threshold too
        update["salarythreshold"] = payload.monthly_income * 0.6 # Example: 60%
    if payload.push_notifications_enabled is not None:
        update["pushenabled"] = payload.push_notifications_enabled
    if payload.whatsapp_alerts_enabled is not None:
        update["whatsappenabled"] = payload.whatsapp_alerts_enabled
    if payload.telegram_alerts_enabled is not None:
        update["telegramenabled"] = payload.telegram_alerts_enabled
    if payload.anonymous_squad_progress is not None:
        update["anonymoussquad"] = payload.anonymous_squad_progress
    if payload.hide_exact_balances is not None:
        update["hidebalances"] = payload.hide_exact_balances
    if payload.card_frozen is not None:
        update["cardfrozen"] = payload.card_frozen
    if payload.spending_limit is not None:
        update["weeklyspendinglimit"] = payload.spending_limit

    if update:
        try:
            exists = db.table("User").select("id").eq("id", user["id"]).limit(1).execute()
            if exists.data:
                db.table("User").update(update).eq("id", user["id"]).execute()
            else:
                update["id"] = user["id"]
                db.table("User").insert(update).execute()
        except Exception as e:
            print(f"[PROFILE] Update error: {e}")
            pass

    return _build_profile(user["id"], user.get("email"))

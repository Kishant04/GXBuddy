from __future__ import annotations

from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, Header

from app.core.database import get_supabase_client, get_admin_client
from app.routers.auth import get_current_user, verify_token
from app.schemas.squad import RallyRequest, RallyResponse, SquadCreate, SquadJoin
from app.services import squad_service

router = APIRouter(prefix="/api/squad", tags=["squad"])


@router.post("/", status_code=201)
async def create_squad(
    payload: SquadCreate,
    user_id: Optional[str] = Query(None),
    authorization: Optional[str] = Header(None),
):
    target_user_id = user_id
    if not target_user_id:
        if not authorization:
            raise HTTPException(status_code=401, detail="Missing user_id or Authorization header")
        try:
            token = authorization.replace("Bearer ", "")
            user = verify_token(token)
            target_user_id = user["id"]
        except Exception:
            raise HTTPException(status_code=401, detail="Authentication failed")

    db = get_supabase_client()
    squad = await squad_service.create_squad(db, target_user_id, payload)
    return {
        "squad_id": squad["id"],
        "invite_code": squad["invitecode"],
        "message": "Squad created!",
    }


@router.post("/join")
async def join_squad(
    payload: SquadJoin,
    user_id: Optional[str] = Query(None),
    authorization: Optional[str] = Header(None),
):
    target_user_id = user_id
    if not target_user_id:
        if not authorization:
            raise HTTPException(status_code=401, detail="Missing user_id or Authorization header")
        try:
            token = authorization.replace("Bearer ", "")
            user = verify_token(token)
            target_user_id = user["id"]
        except Exception:
            raise HTTPException(status_code=401, detail="Authentication failed")

    db = get_supabase_client()
    try:
        squad = await squad_service.join_squad(db, target_user_id, payload.invite_code)
    except ValueError as e:
        raise HTTPException(400, detail=str(e))

    return {
        "squad_id": squad["id"],
        "name": squad["name"],
        "message": "Joined squad!",
    }


@router.get("/my")
async def get_my_squad(
    authorization: Optional[str] = Header(None),
):
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing Authorization header")
    try:
        token = authorization.replace("Bearer ", "")
        user = verify_token(token)
        target_user_id = user["id"]
    except Exception:
        raise HTTPException(status_code=401, detail="Authentication failed")

    db = get_admin_client()
    try:
        membership = (
            db.table("SquadMember")
            .select("squadid")
            .eq("userid", target_user_id)
            .limit(1)
            .execute()
        )

        if not membership.data:
            raise HTTPException(404, detail="User not in any squad")

        squad_id = membership.data[0]["squadid"]
        return await squad_service.get_squad_view(db, squad_id, target_user_id)
    except HTTPException:
        raise
    except Exception as e:
        print(f"[SQUAD] Error in get_my_squad: {e}")
        raise HTTPException(500, detail="Failed to load squad")


@router.get("/by-user/{user_id}")
async def get_squad_by_user(
    user_id: str,
):
    db = get_admin_client()
    try:
        membership = (
            db.table("SquadMember")
            .select("squadid")
            .eq("userid", user_id)
            .limit(1)
            .execute()
        )

        if not membership.data:
            raise HTTPException(404, detail="User not in any squad")

        squad_id = membership.data[0]["squadid"]
        return await squad_service.get_squad_view(db, squad_id, user_id)
    except HTTPException:
        raise
    except Exception as e:
        print(f"[SQUAD] Error in get_squad_by_user: {e}")
        raise HTTPException(500, detail="Failed to load squad")


@router.get("/{squad_id}")
async def get_squad(
    squad_id: str,
    user_id: Optional[str] = Query(None),
    authorization: Optional[str] = Header(None),
):
    target_user_id = user_id
    if not target_user_id:
        if not authorization:
            raise HTTPException(status_code=401, detail="Missing user_id or Authorization header")
        try:
            token = authorization.replace("Bearer ", "")
            user = verify_token(token)
            target_user_id = user["id"]
        except Exception:
            raise HTTPException(status_code=401, detail="Authentication failed")

    db = get_admin_client()
    try:
        return await squad_service.get_squad_view(db, squad_id, target_user_id)
    except ValueError as e:
        raise HTTPException(404, detail=str(e))


@router.post("/{squad_id}/rally", response_model=RallyResponse)
async def rally(
    squad_id: str,
    payload: RallyRequest,
    user_id: Optional[str] = Query(None),
    authorization: Optional[str] = Header(None),
):
    target_user_id = user_id
    if not target_user_id:
        if not authorization:
            raise HTTPException(status_code=401, detail="Missing user_id or Authorization header")
        try:
            token = authorization.replace("Bearer ", "")
            user = verify_token(token)
            target_user_id = user["id"]
        except Exception:
            raise HTTPException(status_code=401, detail="Authentication failed")

    db = get_supabase_client()
    try:
        return await squad_service.send_rally(
            db, squad_id, target_user_id, payload.target_member_index
        )
    except ValueError as e:
        raise HTTPException(400, detail=str(e))
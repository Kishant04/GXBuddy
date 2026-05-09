from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException

from app.core.database import get_supabase_client
from app.routers.auth import get_current_user
from app.schemas.squad import RallyRequest, RallyResponse, SquadCreate, SquadJoin
from app.services import squad_service

router = APIRouter(prefix="/api/squad", tags=["squad"])


@router.post("/", status_code=201)
async def create_squad(
    payload: SquadCreate,
    user=Depends(get_current_user),
):
    db = get_supabase_client()
    squad = await squad_service.create_squad(db, user["id"], payload)
    return {
        "squad_id": squad["id"],
        "invite_code": squad["invite_code"],
        "message": "Squad created!",
    }


@router.post("/join")
async def join_squad(
    payload: SquadJoin,
    user=Depends(get_current_user),
):
    db = get_supabase_client()
    try:
        squad = await squad_service.join_squad(db, user["id"], payload.invite_code)
    except ValueError as e:
        raise HTTPException(400, detail=str(e))

    return {
        "squad_id": squad["id"],
        "name": squad["name"],
        "message": "Joined squad!",
    }


@router.get("/{squad_id}")
async def get_squad(
    squad_id: str,
    user=Depends(get_current_user),
):
    db = get_supabase_client()
    try:
        return await squad_service.get_squad_view(db, squad_id, user["id"])
    except ValueError as e:
        raise HTTPException(404, detail=str(e))


@router.post("/{squad_id}/rally", response_model=RallyResponse)
async def rally(
    squad_id: str,
    payload: RallyRequest,
    user=Depends(get_current_user),
):
    db = get_supabase_client()
    try:
        return await squad_service.send_rally(
            db, squad_id, user["id"], payload.target_member_index
        )
    except ValueError as e:
        raise HTTPException(400, detail=str(e))
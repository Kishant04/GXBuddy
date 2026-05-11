from __future__ import annotations

from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query, Header

from app.schemas.pocket import PocketCreate, PocketResponse
from app.services.pocket_service import (
    create_pocket,
    delete_pocket,
    list_pockets,
    update_pocket,
)
from app.routers.auth import get_current_user, verify_token

router = APIRouter(prefix="/api/pockets", tags=["pockets"])


@router.get("/", response_model=List[PocketResponse])
async def get_pockets(
    user_id: Optional[str] = Query(None),
    authorization: Optional[str] = Header(None),
):
    if user_id:
        return list_pockets(user_id)
    
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing user_id or Authorization header")
    
    try:
        token = authorization.replace("Bearer ", "")
        user = verify_token(token)
        return list_pockets(user["id"])
    except Exception:
        raise HTTPException(status_code=401, detail="Authentication failed")


@router.post("/", status_code=201, response_model=PocketResponse)
async def add_pocket(
    payload: PocketCreate,
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
            
    return create_pocket(target_user_id, payload.model_dump())


@router.patch("/{pocket_id}", response_model=PocketResponse)
async def edit_pocket(
    pocket_id: str,
    payload: PocketCreate,
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

    result = update_pocket(target_user_id, pocket_id, payload.model_dump(exclude_unset=True))
    if not result:
        raise HTTPException(404, "Pocket not found.")
    return result


@router.delete("/{pocket_id}", status_code=204)
async def remove_pocket(
    pocket_id: str,
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

    delete_pocket(target_user_id, pocket_id)

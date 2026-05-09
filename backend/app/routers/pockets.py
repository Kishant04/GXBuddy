from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException

from app.schemas.pocket import PocketCreate, PocketResponse
from app.services.pocket_service import create_pocket, delete_pocket, list_pockets, update_pocket
from app.routers.auth import get_current_user, get_db

router = APIRouter(prefix="/api/pockets", tags=["pockets"])


@router.get("/", response_model=list[PocketResponse])
async def get_pockets(db=Depends(get_db), user=Depends(get_current_user)):
    return await list_pockets(db, user["id"])


@router.post("/", status_code=201, response_model=PocketResponse)
async def add_pocket(
    payload: PocketCreate,
    db=Depends(get_db),
    user=Depends(get_current_user),
):
    return await create_pocket(db, user["id"], payload.model_dump())


@router.patch("/{pocket_id}", response_model=PocketResponse)
async def edit_pocket(
    pocket_id: str,
    payload: PocketCreate,
    db=Depends(get_db),
    user=Depends(get_current_user),
):
    result = await update_pocket(
        db, user["id"], pocket_id, payload.model_dump(exclude_unset=True)
    )
    if not result:
        raise HTTPException(404, "Pocket not found.")
    return result


@router.delete("/{pocket_id}", status_code=204)
async def remove_pocket(
    pocket_id: str,
    db=Depends(get_db),
    user=Depends(get_current_user),
):
    await delete_pocket(db, user["id"], pocket_id)
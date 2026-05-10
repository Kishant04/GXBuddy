from __future__ import annotations

import random
import string
from datetime import datetime


from app.core.websocket_manager import manager


# -----------------------------
# Helpers
# -----------------------------
def _gen_invite_code(length: int = 8) -> str:
    return "".join(random.choices(string.ascii_uppercase + string.digits, k=length))


def _anonymise(members: list, current_user_id: str) -> list[dict]:
    return [
        {
            "member_index": i + 1,
            "progress_score": m.get("progressscore", 0),
            "streak_days": m.get("streakdays", 0),
            "goal_status": m.get("goalstatus", "active"),
            "is_self": m.get("userid") == current_user_id,
        }
        for i, m in enumerate(members)
    ]


# -----------------------------
# CREATE SQUAD
# -----------------------------
async def create_squad(db, user_id: str, data):
    squad_payload = {
        "name": data.name,
        "goalname": data.goal_name,
        "goalamount": data.goal_amount,
        "deadline": str(data.deadline),
        "createdby": user_id,
        "invitecode": _gen_invite_code(),
        "privacymode": data.privacy_mode,
        "isactive": True,
    }

    squad_res = db.table("Squad").insert(squad_payload).execute()
    if not squad_res.data:
        raise Exception("Failed to create squad")

    squad = squad_res.data[0]

    db.table("SquadMember").insert(
        {
            "squadid": squad["id"],
            "userid": user_id,
            "progressscore": 0,
            "streakdays": 0,
            "goalstatus": "active",
        }
    ).execute()

    return squad


# -----------------------------
# JOIN SQUAD
# -----------------------------
async def join_squad(db, user_id: str, invite_code: str):
    squad_res = (
        db.table("Squad")
        .select("*")
        .eq("invitecode", invite_code)
        .eq("isactive", True)
        .execute()
    )

    if not squad_res.data:
        raise ValueError("Invalid or inactive invite code")

    squad = squad_res.data[0]

    existing = (
        db.table("SquadMember")
        .select("*")
        .eq("squadid", squad["id"])
        .eq("userid", user_id)
        .execute()
    )

    if existing.data:
        raise ValueError("Already a member of this squad")

    members = (
        db.table("SquadMember").select("id").eq("squadid", squad["id"]).execute()
    )

    if len(members.data) >= 5:
        raise ValueError("Squad is full (max 5 members)")

    db.table("SquadMember").insert(
        {
            "squadid": squad["id"],
            "userid": user_id,
            "progressscore": 0,
            "streakdays": 0,
            "goalstatus": "active",
        }
    ).execute()

    return squad


# -----------------------------
# GET SQUAD VIEW
# -----------------------------
async def get_squad_view(db, squad_id: str, current_user_id: str):
    squad_res = db.table("Squad").select("*").eq("id", squad_id).single().execute()

    if not squad_res.data:
        raise ValueError("Squad not found")

    squad = squad_res.data

    members_res = (
        db.table("SquadMember").select("*").eq("squadid", squad_id).execute()
    )
    members = members_res.data or []

    days_remaining = max(
        0,
        (datetime.fromisoformat(squad["deadline"]) - datetime.utcnow()).days,
    )

    anon_members = _anonymise(members, current_user_id)

    from app.ai.squad_insights import generate_squad_insight
    ai_insight = await generate_squad_insight(
        members_data=[
            {
                "index": m["member_index"],
                "progress": m["progress_score"],   # fixed key
                "streak": m["streak_days"],          # fixed key
                "goal_status": m["goal_status"],     # fixed key
            }
            for m in anon_members
        ],
        goal_name=squad["goalname"],
        days_remaining=days_remaining,
    )

    avg_progress = (
        round(sum(m["progress_score"] for m in anon_members) / len(anon_members), 1)
        if anon_members else 0.0
    )

    return {
        "squad_id": squad["id"],
        "squadid": squad["id"],          # keep alias for old clients
        "name": squad["name"],
        "goal_name": squad["goalname"],
        "goal_amount": float(squad.get("goalamount") or 0),
        "deadline": squad["deadline"],
        "invite_code": squad["invitecode"],
        "privacy_mode": squad.get("privacymode", "ANONYMOUS"),
        "progress": avg_progress,
        "members": anon_members,
        "insight": ai_insight,
        "ai_insight": ai_insight,        # keep alias
    }


# -----------------------------
# SEND RALLY (WebSocket)
# -----------------------------
async def send_rally(db, squad_id: str, sender_user_id: str, target_member_index: int):
    members_res = (
        db.table("SquadMember").select("*").eq("squadid", squad_id).execute()
    )
    members = members_res.data or []

    if target_member_index < 1 or target_member_index > len(members):
        raise ValueError("Invalid member index")

    target_member = members[target_member_index - 1]

    sender_index = next(
        (i + 1 for i, m in enumerate(members) if m["userid"] == sender_user_id),
        0,
    )

    # Use send_to_user (correct method on ConnectionManager)
    await manager.send_to_user(
        target_member["userid"],
        {
            "type": "rally",
            "data": {
                "from_member_index": sender_index,
                "message": "Hold Strong 💪",
            },
        },
    )

    return {"sent": True, "message": f"Rally sent to Member {target_member_index}!"}


# -----------------------------
# STREAK SHIELD ALERT
# -----------------------------
async def check_streak_shield(db, user_id: str, squad_id: str):
    member_res = (
        db.table("SquadMember")
        .select("*")
        .eq("squadid", squad_id)
        .eq("userid", user_id)
        .execute()
    )

    if not member_res.data:
        return

    streak_res = (
        db.table("streaks").select("*").eq("userid", user_id).execute()
    )
    streak = streak_res.data[0] if streak_res.data else None

    if not streak or streak.get("current_streak", 0) < 1:
        return

    members_res = (
        db.table("SquadMember").select("*").eq("squadid", squad_id).execute()
    )
    members = members_res.data or []

    member_index = next(
        (i + 1 for i, m in enumerate(members) if m["userid"] == user_id),
        0,
    )

    for m in members:
        if m["userid"] == user_id:
            continue
        await manager.send_to_user(
            m["userid"],
            {
                "type": "streak_shield",
                "data": {
                    "member_index": member_index,
                    "squadid": squad_id,
                    "message": f"Member {member_index} is 1 purchase away from losing the streak. Rally? 🛡️",
                },
            },
        )


# -----------------------------
# UPDATE PROGRESS SCORE
# -----------------------------
async def update_progress_score(db, user_id: str):
    memberships_res = (
        db.table("SquadMember").select("*").eq("userid", user_id).execute()
    )
    memberships = memberships_res.data or []

    streak_res = (
        db.table("streaks").select("*").eq("userid", user_id).execute()
    )
    streak = streak_res.data[0] if streak_res.data else None
    streak_days = streak.get("current_streak", 0) if streak else 0

    streak_score = min(streak_days / 30 * 100, 100) * 0.4

    for m in memberships:
        db.table("SquadMember").update(
            {"progressscore": round(streak_score, 1), "streakdays": streak_days}
        ).eq("id", m["id"]).execute()
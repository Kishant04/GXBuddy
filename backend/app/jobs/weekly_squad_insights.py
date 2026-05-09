from apscheduler.schedulers.asyncio import AsyncIOScheduler

from app.core.database import get_supabase_client
from app.services.squad_service import get_squad_view
from app.core.websocket_manager import manager

scheduler = AsyncIOScheduler()


@scheduler.scheduled_job("cron", day_of_week="mon", hour=9, minute=0)
async def run_weekly_squad_insights():
    db = get_supabase_client()

    try:
        # fetch all active squads
        squads_res = (
            db.table("squads")
            .select("*")
            .eq("is_active", True)
            .execute()
        )

        squads = squads_res.data or []

        for squad in squads:
            try:
                # fetch squad members
                members_res = (
                    db.table("squad_members")
                    .select("*")
                    .eq("squad_id", squad["id"])
                    .execute()
                )

                members = members_res.data or []

                if not members:
                    continue

                creator_id = squad["created_by"]

                # generate AI insight
                view = await get_squad_view(
                    db,
                    squad["id"],
                    creator_id
                )

                # push insight to all members
                for member in members:
                    await manager.send_personal_message(
                        member["user_id"],
                        {
                            "type": "squad_insight",
                            "data": {
                                "squad_id": squad["id"],
                                "squad_name": squad["name"],
                                "insight": view["ai_insight"],
                            },
                        },
                    )

                print(f"[WeeklyInsights] Success for squad {squad['id']}")

            except Exception as e:
                print(f"[WeeklyInsights] Squad {squad['id']} failed: {e}")

    except Exception as e:
        print(f"[WeeklyInsights] Scheduler failed: {e}")
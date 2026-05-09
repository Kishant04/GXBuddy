from __future__ import annotations

from app.ai.prompts import llm_json_completion


async def generate_squad_insight(
    members_data: list[dict],
    goal_name: str,
    days_remaining: int,
) -> str:
    result = llm_json_completion(
        system_prompt=(
            "You are GX Buddy, a financial companion for Malaysian youth. "
            "Given anonymised squad member data, write one short motivational insight paragraph "
            "in Malaysian English. Mention who needs a nudge by member index only (e.g. 'Member 3'). "
            "Return JSON with key insight only."
        ),
        user_prompt=(
            f"goal={goal_name}\ndays_remaining={days_remaining}\nmembers={members_data}"
        ),
    )
    if not result:
        return "Keep going squad! Every ringgit saved brings you closer to the goal. 💪"
    return str(result.get("insight", "")).strip() or "Keep pushing squad, you got this!"
from __future__ import annotations

from app.ai.prompts import SQUAD_INSIGHT_SYSTEM_PROMPT, llm_json_completion


async def generate_squad_insight(
    members_data: list[dict],
    goal_name: str,
    days_remaining: int,
) -> dict:
    result = llm_json_completion(
        system_prompt=SQUAD_INSIGHT_SYSTEM_PROMPT,
        user_prompt=(
            f"goal={goal_name}\ndays_remaining={days_remaining}\nmembers={members_data}"
        ),
    )
    if not result:
        return {
            "paragraph": "Keep going squad! Every ringgit saved brings you closer to the goal. 💪",
            "nudge_targets": [],
            "collective_action": "Keep the momentum going by saving RM10 each today."
        }
    
    return {
        "paragraph": str(result.get("paragraph", "")).strip() or "Keep pushing squad, you got this!",
        "nudge_targets": result.get("nudge_targets", []),
        "collective_action": str(result.get("collective_action", "")).strip() or "Keep saving together!"
    }
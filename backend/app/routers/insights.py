from __future__ import annotations

from fastapi import APIRouter, Depends, Query

from app.ai.prompts import SPEND_INSIGHT_SYSTEM_PROMPT, llm_json_completion
from app.core.database import TABLES, get_supabase_client
from app.core.utils import to_decimal, week_bounds
from app.routers.auth import get_current_user

router = APIRouter(prefix="/api/insights", tags=["insights"])


@router.get("")
async def get_spend_insight(
    user_id: str = Query(...),
    user=Depends(get_current_user),
):
    """
    Generates a personalised weekly spending insight using Gemini (or GLM fallback).
    Returns { insight, category_highlight, tip, total_spent, top_category }
    """
    db = get_supabase_client()
    start, end = week_bounds()

    tx_res = (
        db.table(TABLES["transactions"])
        .select("amount, category, merchant")
        .eq("userid", user_id)
        .gte("timestamp", start.isoformat())
        .lt("timestamp", end.isoformat())
        .execute()
    )
    rows = tx_res.data or []

    # Build category totals
    category_totals: dict[str, float] = {}
    total_spent = 0.0
    for row in rows:
        cat = str(row.get("category") or "other").lower()
        if cat == "salary":
            continue
        amt = float(to_decimal(row.get("amount")))
        category_totals[cat] = category_totals.get(cat, 0.0) + amt
        total_spent += amt

    if not category_totals:
        return {
            "insight": "No spending recorded this week. Great start! 🌟",
            "category_highlight": None,
            "tip": "Set up a weekly budget to track your spending.",
            "total_spent": 0.0,
            "top_category": None,
        }

    top_category = max(category_totals, key=lambda k: category_totals[k])
    top_amount = category_totals[top_category]

    breakdown_text = ", ".join(
        f"{cat}: RM{amt:.0f}" for cat, amt in
        sorted(category_totals.items(), key=lambda x: x[1], reverse=True)[:5]
    )

    ai_result = llm_json_completion(
        system_prompt=SPEND_INSIGHT_SYSTEM_PROMPT,
        user_prompt=(
            f"total_spent=RM{total_spent:.2f}\n"
            f"breakdown={breakdown_text}\n"
            f"top_category={top_category} (RM{top_amount:.2f})"
        ),
    )

    if ai_result:
        return {
            "insight": ai_result.get("insight", ""),
            "category_highlight": ai_result.get("category_highlight", top_category),
            "tip": ai_result.get("tip", ""),
            "total_spent": round(total_spent, 2),
            "top_category": top_category,
        }

    # Fallback template
    pct = round(top_amount / total_spent * 100) if total_spent > 0 else 0
    return {
        "insight": (
            f"You've spent RM{total_spent:.0f} this week. "
            f"{top_category.capitalize()} is your biggest category at {pct}% of your spending."
        ),
        "category_highlight": top_category,
        "tip": "Try the 50/30/20 rule — 50% needs, 30% wants, 20% savings.",
        "total_spent": round(total_spent, 2),
        "top_category": top_category,
    }

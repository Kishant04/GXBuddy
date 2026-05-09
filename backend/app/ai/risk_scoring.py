from __future__ import annotations

"""Explainable deterministic overspending risk scoring for Feature 1."""

from dataclasses import dataclass

from app.ai.validators import require_non_negative_number
from app.core.utils import clamp
from app.schemas.contracts import RiskBand, RiskResultSchema


@dataclass
class RiskInput:
	"""Inputs used to produce a transparent 0-100 risk score."""

	weekly_spend_so_far: float
	budget_limit: float
	category_overspend_ratio: float
	late_night_spending: bool
	upcoming_bills_total: float
	spending_frequency: int
	historical_average: float
	amount: float
	time_of_day: int | None = None


def calculate_risk_score(data: RiskInput) -> RiskResultSchema:
	"""Compute a deterministic risk score without delegating money logic to AI."""
	require_non_negative_number(data.weekly_spend_so_far, "weekly_spend_so_far")
	require_non_negative_number(data.budget_limit, "budget_limit")
	require_non_negative_number(data.category_overspend_ratio, "category_overspend_ratio")
	require_non_negative_number(data.upcoming_bills_total, "upcoming_bills_total")
	require_non_negative_number(data.spending_frequency, "spending_frequency")
	require_non_negative_number(data.historical_average, "historical_average")
	require_non_negative_number(data.amount, "amount")

	score = 0.0
	reasons: list[str] = []

	if data.budget_limit > 0:
		budget_use = (data.weekly_spend_so_far / data.budget_limit) * 100
		score += clamp((budget_use - 50) * 0.6, 0, 35)
		if budget_use >= 80:
			reasons.append("Weekly budget usage is high")

	score += clamp((data.category_overspend_ratio - 1.0) * 25, 0, 20)
	if data.category_overspend_ratio >= 1.2:
		reasons.append("Category spending is above normal pattern")

	if data.late_night_spending:
		score += 15
		reasons.append("Late-night transaction detected")
	elif data.time_of_day is not None and 21 <= data.time_of_day < 23:
		score += 5
		reasons.append("Evening spending window adds mild impulse risk")

	if data.upcoming_bills_total > 0:
		score += clamp(data.upcoming_bills_total / 50, 0, 10)
		reasons.append("Upcoming unpaid bills reduce spending buffer")

	score += clamp((data.spending_frequency - 3) * 3, 0, 10)
	if data.spending_frequency >= 5:
		reasons.append("High weekly transaction frequency")

	if data.historical_average > 0 and data.amount > data.historical_average * 1.6:
		score += 10
		reasons.append("Transaction amount is above historical average")
	elif data.amount >= 100:
		score += 6
		reasons.append("Transaction amount is moderately high")

	normalized = round(clamp(score, 0, 100), 2)

	if normalized <= 39:
		band = RiskBand.CALM
	elif normalized <= 69:
		band = RiskBand.ALERT
	elif normalized <= 89:
		band = RiskBand.PANICKED
	else:
		band = RiskBand.EMERGENCY

	if not reasons:
		reasons.append("Spending pattern is within expected range")

	return RiskResultSchema(score=normalized, band=band, reasons=reasons)

def score_risk(context: dict) -> float:
    """
    Rule-based risk scorer — no AI needed here, fast and deterministic.
    Returns 0–100.
    """
    score = 0.0
    budgets = {b["category"]: b for b in context.get("budgets", [])}
    cat     = context.get("category", "")
    amount  = float(context.get("amount", 0))
    hour    = int(context.get("time_of_day", 12))

    # Late night spending boost (+15)
    if hour >= 23 or hour <= 4:
        score += 15

    # Budget breach
    if cat in budgets:
        b          = budgets[cat]
        weekly_lim = float(b.get("weekly_limit", 1))
        weekly_sp  = float(context.get("weekly_spend", 0))
        pct        = (weekly_sp + amount) / weekly_lim * 100 if weekly_lim > 0 else 0
        if pct >= 100: score += 40
        elif pct >= 80: score += 25
        elif pct >= 60: score += 10

    # Upcoming bills within 3 days (+20)
    from datetime import datetime, timedelta
    soon = datetime.utcnow() + timedelta(days=3)
    for bill in context.get("upcoming_bills", []):
        try:
            due = datetime.fromisoformat(bill["due_date"])
            if due <= soon:
                score += 20
                break
        except Exception:
            pass

    return min(round(score, 1), 100.0)

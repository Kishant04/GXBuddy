from __future__ import annotations

"""Deterministic-first spending classification for Feature 1 transactions."""

import json
from dataclasses import dataclass
from datetime import datetime

from app.ai.prompts import CLASSIFIER_SYSTEM_PROMPT, llm_json_completion
from app.ai.validators import (
    is_late_night,
    normalize_text,
    require_non_empty_text,
    require_positive_number,
)
from app.schemas.contracts import ClassificationResult, SpendingClass


@dataclass
class ClassificationInput:
    """Input features used to classify a transaction into spending behavior buckets."""

    merchant: str
    category: str | None
    amount: float
    timestamp: datetime
    source: str
    historical_average: float = 0.0
    weekly_frequency: int = 0


def _classify_with_llm(data: ClassificationInput) -> ClassificationResult | None:
    """Ask the configured LLM for an ambiguous merchant classification, if available."""
    result = llm_json_completion(
        system_prompt=(
            "Classify a financial transaction. Return JSON with keys primary, confidence, reason. "
            "primary must be one of essential, lifestyle, risky, unusual, salary, bill."
        ),
        user_prompt=(
            f"merchant={data.merchant}\n"
            f"category={data.category or ''}\n"
            f"amount={data.amount}\n"
            f"source={data.source}\n"
            f"weekly_frequency={data.weekly_frequency}\n"
            f"historical_average={data.historical_average}"
        ),
    )
    if not result:
        return None

    primary_raw = str(result.get("primary", "")).strip().lower()
    if primary_raw not in {item.value for item in SpendingClass}:
        return None

    primary = SpendingClass(primary_raw)
    confidence = float(result.get("confidence", 0.55))
    reason = str(result.get("reason", "AI fallback classification"))
    return ClassificationResult(
        primary=primary,
        tags=[primary],
        confidence=max(0.0, min(confidence, 1.0)),
        reason=reason,
    )


def _looks_ambiguous(merchant: str, category_hint: str) -> bool:
    """Return True when rule-based matching has weak merchant/category clues."""
    if len(merchant) < 4:
        return True
    if merchant.replace(" ", "").isalnum() and any(char.isdigit() for char in merchant):
        return True
    return not category_hint and all(
        token not in merchant for token in ["grab", "food", "shop", "bill", "salary"]
    )


def classify_spending(data: ClassificationInput) -> ClassificationResult:
    """Classify a transaction with deterministic rules and optional AI fallback."""
    require_non_empty_text(data.merchant, "merchant")
    require_positive_number(data.amount, "amount")

    merchant = normalize_text(data.merchant)
    source = normalize_text(data.source)
    category_hint = normalize_text(data.category)

    tags: list[SpendingClass] = []
    reason = "Mapped by fallback lifestyle rule"
    confidence = 0.6
    primary = SpendingClass.LIFESTYLE

    if "salary" in source or any(k in merchant for k in ["salary", "payroll", "gaji"]):
        primary = SpendingClass.SALARY
        reason = "Detected salary-like transaction source or merchant"
        confidence = 0.95
    elif any(k in merchant for k in ["celcom", "maxis", "unifi", "tenaga", "astro", "bill", "tm"]):
        primary = SpendingClass.BILL
        reason = "Merchant matched bill provider keywords"
        confidence = 0.92
    elif any(k in merchant for k in ["grabfood", "foodpanda", "shopee", "lazada", "tiktok shop"]):
        primary = SpendingClass.LIFESTYLE
        reason = "Merchant matched lifestyle spending platform"
        confidence = 0.88
    elif any(k in category_hint for k in ["grocer", "medical", "transport", "education"]):
        primary = SpendingClass.ESSENTIAL
        reason = "Category hint indicates essential spending"
        confidence = 0.8

    if is_late_night(data.timestamp) and any(
        k in merchant for k in ["grabfood", "foodpanda", "shopee", "lazada"]
    ):
        tags.append(SpendingClass.RISKY)
        reason = "Late-night discretionary spending pattern"
        confidence = max(confidence, 0.9)

    if data.historical_average > 0 and data.amount >= data.historical_average * 1.8:
        tags.append(SpendingClass.UNUSUAL)
        reason = "Amount is significantly above historical average"
        confidence = max(confidence, 0.9)

    if data.weekly_frequency >= 3 and primary in {SpendingClass.LIFESTYLE, SpendingClass.BILL}:
        tags.append(SpendingClass.RISKY)
        reason = "High weekly frequency in the same spending cluster"

    if confidence < 0.7 and _looks_ambiguous(merchant, category_hint):
        llm_result = _classify_with_llm(data)
        if llm_result is not None:
            primary = llm_result.primary
            confidence = llm_result.confidence
            reason = llm_result.reason
            tags = llm_result.tags[:]

    if primary not in tags:
        tags.insert(0, primary)

    return ClassificationResult(primary=primary, tags=tags, confidence=confidence, reason=reason)


KEYWORD_MAP = {
    "grabfood": "food",
    "foodpanda": "food",
    "mcdonalds": "food",
    "grab": "transport",
    "myrapid": "transport",
    "touch n go": "transport",
    "salary": "salary",
    "gaji": "salary",
    "payroll": "salary",
    "celcom": "bill",
    "unifi": "bill",
    "ptptn": "bill",
}


def classify_transaction(context: dict) -> dict:
    """Synchronous keyword-first classifier with LLM fallback."""
    merchant = context.get("merchant", "").lower()
    for kw, cat in KEYWORD_MAP.items():
        if kw in merchant:
            return {"category": cat, "label": cat, "confidence": 0.95}

    result = llm_json_completion(
        system_prompt=CLASSIFIER_SYSTEM_PROMPT,
        user_prompt=json.dumps(context),
    )
    if result:
        return {
            "category": result.get("category", context.get("category", "lifestyle")),
            "label": result.get("label", "lifestyle"),
            "confidence": result.get("confidence", 0.5),
        }
    return {
        "category": context.get("category", "lifestyle"),
        "label": "lifestyle",
        "confidence": 0.5,
    }
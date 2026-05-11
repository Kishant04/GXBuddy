from __future__ import annotations

"""LLM helpers for GXBuddy AI features.

Uses Google Gemini when GEMINI_API_KEY is set, falls back to GLM (Ilmu).
All money decisions stay deterministic in code — LLM is used for
wording/insight generation only. Any failure returns None so callers
fall back to safe template text.
"""

import json
import httpx
from app.core.config import settings

# ── Prompt constants ──────────────────────────────────────────────────────────

NUDGE_STYLE_GUIDE = (
    "Use short Malaysian-English friendly tone, avoid judgment, include one concrete next action."
)

ROUND_UP_ACTION = "round_up_save"
SLOW_DOWN_ACTION = "slow_down"
REVIEW_BUDGET_ACTION = "review_budget"
PAUSE_AND_THINK_ACTION = "pause_and_think"

NUDGE_SYSTEM_PROMPT = """
You are GX Buddy, a financial companion for Malaysian youth.
Given spending context, generate ONE short alert in Malaysian English (mix in Malay words naturally).
Max 2 sentences. Be real and friendly, not preachy or scolding.
Return ONLY valid JSON, no markdown fences:
{"message": "...", "severity": "calm|alert|panicked", "action": "..."}
"""

MASCOT_SYSTEM_PROMPT = """
You are GX Buddy's emotion engine.
Given weekly spending stats, return the mascot's emotional state.
Return ONLY valid JSON, no markdown fences:
{"state": "CALM|WORRIED|ALERT|PANICKED|CELEBRATING", "mood_line": "<short casual Malaysian English line, max 15 words>"}
"""

SQUAD_INSIGHT_SYSTEM_PROMPT = """
You are GX Buddy, a financial coach for a Malaysian youth saving squad.
Members are labelled "Member 1", "Member 2" etc — never use real names.
Return ONLY valid JSON, no markdown fences:
{
  "paragraph": "<2-3 sentence squad overview in friendly Malaysian English>",
  "nudge_targets": ["Member X"],
  "collective_action": "<one specific action the whole squad should do this week>"
}
Rules: be encouraging not shaming. Add member to nudge_targets if progress < 40% and days_remaining < 14.
collective_action must be specific e.g. "Skip one makan luar each, save RM15 each".
"""

SPEND_INSIGHT_SYSTEM_PROMPT = """
You are GX Buddy, a financial companion for Malaysian youth.
Given a user's weekly spending breakdown, generate a SHORT personalised insight (2-3 sentences max).
Use friendly Malaysian English. Be specific about the biggest spending category.
Mention a practical tip. Return ONLY valid JSON:
{"insight": "...", "category_highlight": "...", "tip": "..."}
"""

CLASSIFIER_SYSTEM_PROMPT = """
You classify Malaysian financial transactions.
Given merchant name, amount, category hint and time, return ONLY valid JSON:
{"category": "food|transport|salary|bill|lifestyle|essential|risky|unusual", "label": "...", "confidence": 0.0-1.0}
No markdown. One word category only.
"""

# ── Gemini client ─────────────────────────────────────────────────────────────

def _gemini_json_completion(
    system_prompt: str, user_prompt: str, api_key: str
) -> dict | None:
    model = settings.GEMINI_MODEL
    url = (
        f"https://generativelanguage.googleapis.com/v1beta/models/"
        f"{model}:generateContent?key={api_key}"
    )
    combined = f"{system_prompt.strip()}\n\n{user_prompt.strip()}"
    payload = {
        "contents": [{"parts": [{"text": combined}]}],
        "generationConfig": {
            "temperature": 0.2,
            "responseMimeType": "application/json",
        },
    }
    try:
        with httpx.Client(timeout=8.0) as client:
            resp = client.post(
                url,
                json=payload,
                headers={"Content-Type": "application/json"},
            )
            resp.raise_for_status()
            data = resp.json()
            text = data["candidates"][0]["content"]["parts"][0]["text"]
            if isinstance(text, list):
                text = "".join(
                    part.get("text", "") for part in text if isinstance(part, dict)
                )
            return json.loads(text)
    except Exception:
        return None


# ── GLM / OpenAI-compatible client ───────────────────────────────────────────

def _get_base_url() -> str:
    url = settings.GLM_BASE_URL
    if not url.endswith("/chat/completions"):
        url = url.rstrip("/") + "/chat/completions"
    return url


def _glm_json_completion(
    system_prompt: str, user_prompt: str, api_key: str
) -> dict | None:
    payload = {
        "model": settings.GLM_MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        "temperature": 0.2,
        "response_format": {"type": "json_object"},
    }
    try:
        with httpx.Client(timeout=8.0) as client:
            resp = client.post(
                _get_base_url(),
                headers={
                    "Authorization": f"Bearer {api_key}",
                    "Content-Type": "application/json",
                },
                json=payload,
            )
            resp.raise_for_status()
            data = resp.json()
            content = data["choices"][0]["message"]["content"]
            if isinstance(content, list):
                content = "".join(
                    part.get("text", "") for part in content if isinstance(part, dict)
                )
            return json.loads(content)
    except Exception:
        return None


# ── Public entry point ────────────────────────────────────────────────────────

def llm_json_completion(system_prompt: str, user_prompt: str) -> dict | None:
    """
    Try GLM first (primary fallback), then Gemini if available.
    """
    glm_key = settings.GLM_API_KEY
    if glm_key:
        result = _glm_json_completion(system_prompt, user_prompt, glm_key)
        if result is not None:
            return result

    gemini_key = settings.GEMINI_API_KEY
    if gemini_key:
        return _gemini_json_completion(system_prompt, user_prompt, gemini_key)

    return None

from __future__ import annotations

"""Prompt and optional LLM helpers for Feature 1 wording tasks.

All money decisions remain deterministic in code. The LLM is only used as a best-effort
fallback for ambiguous merchant labeling or friendlier wording. Any failure returns None
so callers can fall back to safe template text.
"""

import json
import os

import httpx

NUDGE_STYLE_GUIDE = (
	"Use short Malaysian-English friendly tone, avoid judgment, include one concrete next action."
)

ROUND_UP_ACTION = "round_up_save"
SLOW_DOWN_ACTION = "slow_down"
REVIEW_BUDGET_ACTION = "review_budget"
PAUSE_AND_THINK_ACTION = "pause_and_think"

DEFAULT_MODEL = "ilmu-glm-5.1"
DEFAULT_BASE_URL = "https://api.ilmu.ai/v1/chat/completions"


def _get_api_key() -> str | None:
	return os.getenv("GLM_API_KEY") or os.getenv("ilmu_api_key") or os.getenv("AI_API_KEY")


def _get_base_url() -> str:
	return os.getenv("GLM_BASE_URL") or os.getenv("AI_BASE_URL") or DEFAULT_BASE_URL


def _get_model() -> str:
	return os.getenv("GLM_MODEL") or os.getenv("AI_MODEL") or DEFAULT_MODEL


def llm_json_completion(system_prompt: str, user_prompt: str) -> dict | None:
	"""Return parsed JSON from the configured LLM provider or None on any failure."""
	api_key = _get_api_key()
	if not api_key:
		return None

	payload = {
		"model": _get_model(),
		"messages": [
			{"role": "system", "content": system_prompt},
			{"role": "user", "content": user_prompt},
		],
		"temperature": 0.2,
		"response_format": {"type": "json_object"},
	}

	try:
		with httpx.Client(timeout=4.0) as client:
			response = client.post(
				_get_base_url(),
				headers={
					"Authorization": f"Bearer {api_key}",
					"Content-Type": "application/json",
				},
				json=payload,
			)
			response.raise_for_status()
			data = response.json()
			content = data["choices"][0]["message"]["content"]
			if isinstance(content, list):
				content = "".join(part.get("text", "") for part in content if isinstance(part, dict))
			return json.loads(content)
	except Exception:
		return None


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
{"state": "CALM|ALERT|PANICKED|CELEBRATING", "mood_line": "<short casual Malaysian English line, max 15 words>"}
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

CLASSIFIER_SYSTEM_PROMPT = """
You classify Malaysian financial transactions.
Given merchant name, amount, category hint and time, return ONLY valid JSON:
{"category": "food|transport|salary|bill|lifestyle|essential|risky|unusual", "label": "...", "confidence": 0.0-1.0}
No markdown. One word category only.
"""
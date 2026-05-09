import httpx, json
from app.core.config import settings

async def glm_chat(system_prompt: str, user_content: str, max_tokens: int = 400) -> str:
    """
    Calls Ilmu GLM (OpenAI-compatible format).
    Returns the assistant message string.
    """
    async with httpx.AsyncClient(timeout=15) as client:
        resp = await client.post(
            f"{settings.GLM_BASE_URL}/chat/completions",
            headers={
                "Authorization": f"Bearer {settings.GLM_API_KEY}",
                "Content-Type":  "application/json",
            },
            json={
                "model": settings.GLM_MODEL,
                "max_tokens": max_tokens,
                "messages": [
                    {"role": "system",  "content": system_prompt},
                    {"role": "user",    "content": user_content},
                ],
            },
        )
    resp.raise_for_status()
    return resp.json()["choices"][0]["message"]["content"]

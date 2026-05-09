import pytest
from httpx import AsyncClient
from app.main import app

BASE = "/api/squad"

@pytest.mark.asyncio
async def test_create_squad(auth_headers):
    async with AsyncClient(app=app, base_url="http://test") as ac:
        r = await ac.post(BASE + "/", json={
            "name":        "Bro Savers",
            "goal_name":   "Raya Fund",
            "goal_amount": 500,
            "deadline":    "2025-03-31T00:00:00",
            "privacy_mode":"ANONYMOUS",
        }, headers=auth_headers)
    assert r.status_code == 201
    assert "invite_code" in r.json()

@pytest.mark.asyncio
async def test_join_squad(auth_headers_2, invite_code):
    async with AsyncClient(app=app, base_url="http://test") as ac:
        r = await ac.post(BASE + "/join", json={"invite_code": invite_code}, headers=auth_headers_2)
    assert r.status_code == 200
    assert r.json()["message"] == "Joined squad!"

@pytest.mark.asyncio
async def test_get_squad_view(auth_headers, squad_id):
    async with AsyncClient(app=app, base_url="http://test") as ac:
        r = await ac.get(f"{BASE}/{squad_id}", headers=auth_headers)
    assert r.status_code == 200
    data = r.json()
    assert "ai_insight" in data
    assert "members" in data
    # Privacy: no raw RM amounts
    for m in data["members"]:
        assert "progress_score" in m
        assert "balance" not in m

@pytest.mark.asyncio
async def test_rally(auth_headers, squad_id):
    async with AsyncClient(app=app, base_url="http://test") as ac:
        r = await ac.post(f"{BASE}/{squad_id}/rally",
                          json={"target_member_index": 2},
                          headers=auth_headers)
    assert r.status_code == 200
    assert r.json()["sent"] is True

@pytest.mark.asyncio
async def test_ai_insight_fallback(monkeypatch, auth_headers, squad_id):
    """If Claude is down, endpoint should still return squad data (graceful degrade)."""
    import app.ai.squad_insights as si
    async def mock_fail(*a, **kw):
        raise Exception("Claude timeout")
    monkeypatch.setattr(si, "generate_squad_insight", mock_fail)

    async with AsyncClient(app=app, base_url="http://test") as ac:
        r = await ac.get(f"{BASE}/{squad_id}", headers=auth_headers)
    assert r.status_code == 200
    assert r.json()["ai_insight"] is None 
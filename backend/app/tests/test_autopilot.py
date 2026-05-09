import pytest
from httpx import AsyncClient
from app.main import app

BASE_TXN  = "/api/transactions"
BASE_AUTO = "/api/autopilot"
BASE_PKT  = "/api/pockets"

@pytest.mark.asyncio
async def test_create_pocket(auth_headers):
    async with AsyncClient(app=app, base_url="http://test") as ac:
        r = await ac.post(BASE_PKT + "/", json={
            "name":       "Emergency Fund",
            "target":     580,
            "split_rule": {"type": "percent", "value": 20}
        }, headers=auth_headers)
    assert r.status_code == 201
    assert r.json()["name"] == "Emergency Fund"

@pytest.mark.asyncio
async def test_salary_triggers_autopilot(auth_headers):
    async with AsyncClient(app=app, base_url="http://test") as ac:
        r = await ac.post(BASE_TXN + "/", json={
            "amount":   3500,
            "merchant": "Employer Payroll",
            "category": "salary",
            "source":   "transfer",
        }, headers=auth_headers)
    assert r.status_code == 200
    data = r.json()
    assert data["autopilot_fired"] is True
    assert data["autopilot_summary"]["total_routed"] > 0
    assert len(data["autopilot_summary"]["lines"]) > 0

@pytest.mark.asyncio
async def test_undo_within_window(auth_headers):
    # First trigger a split
    async with AsyncClient(app=app, base_url="http://test") as ac:
        txn = await ac.post(BASE_TXN + "/", json={
            "amount": 3500, "merchant": "Payroll", "category": "salary", "source": "transfer"
        }, headers=auth_headers)
        split_id = txn.json()["autopilot_summary"]["split_id"]

        r = await ac.post(BASE_AUTO + "/undo", json={"split_id": split_id}, headers=auth_headers)
    assert r.json()["reversed"] is True

@pytest.mark.asyncio
async def test_undo_after_expiry(auth_headers, monkeypatch):
    from datetime import datetime, timedelta
    import app.services.autopilot_service as svc

    async with AsyncClient(app=app, base_url="http://test") as ac:
        txn = await ac.post(BASE_TXN + "/", json={
            "amount": 3500, "merchant": "Payroll", "category": "salary", "source": "transfer"
        }, headers=auth_headers)
        split_id = txn.json()["autopilot_summary"]["split_id"]

    # Manually expire the undo window
    svc._pending_undos[split_id]["expires_at"] = datetime.utcnow() - timedelta(seconds=1)

    async with AsyncClient(app=app, base_url="http://test") as ac:
        r = await ac.post(BASE_AUTO + "/undo", json={"split_id": split_id}, headers=auth_headers)
    assert r.json()["reversed"] is False
    assert "expired" in r.json()["message"].lower()

@pytest.mark.asyncio
async def test_non_salary_no_autopilot(auth_headers):
    async with AsyncClient(app=app, base_url="http://test") as ac:
        r = await ac.post(BASE_TXN + "/", json={
            "amount": 45, "merchant": "GrabFood", "category": "food", "source": "card"
        }, headers=auth_headers)
    assert r.json()["autopilot_fired"] is False

@pytest.mark.asyncio
async def test_gig_worker_percent_split(auth_headers):
    """Gig worker gets variable income — split rule is %, adapts automatically."""
    async with AsyncClient(app=app, base_url="http://test") as ac:
        # Post irregular income
        r = await ac.post(BASE_TXN + "/", json={
            "amount": 820, "merchant": "Grab Driver Earnings", "category": "salary", "source": "transfer"
        }, headers=auth_headers)
    data = r.json()
    assert data["autopilot_fired"] is True
    # 20% of 820 = 164
    routed = data["autopilot_summary"]["total_routed"]
    assert routed == pytest.approx(164.0, abs=1.0)
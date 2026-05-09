from __future__ import annotations

from datetime import datetime
from decimal import Decimal

from fastapi.testclient import TestClient

from app.main import app
from app.ai.mascot_engine import MascotInput, determine_mascot_state
from app.routers import transactions as transactions_router_module
from app.schemas.common import AlertSeverity, MascotState
from app.schemas.transaction import (
    ClassificationResult,
    NudgeResponse,
    RiskResult,
    TransactionRead,
    TransactionResponse,
)
from app.services.transaction_service import TransactionService


# ── Shared fake transaction ──────────────────────────────────────
def _make_transaction(amount: str = "45.00", category: str = "FOOD") -> TransactionRead:
    return TransactionRead(
        id="tx-test-1",
        user_id="u-1",
        amount=Decimal(amount),
        merchant="GrabFood",
        category=category,
        source="MANUAL",
        status="POSTED",
        external_ref=None,
        risk_score=20.0,
        category_confidence=0.95,
        is_bnpl=False,
        alert_generated=False,
        timestamp=datetime.utcnow(),
    )


def _make_response(mascot_state: str, mood_line: str, amount: str = "45.00") -> TransactionResponse:
    from app.schemas.common import MascotResponse
    return TransactionResponse(
        transaction=_make_transaction(amount),
        classification="FOOD",
        risk_score=20.0,
        mascot=MascotResponse(state=MascotState(mascot_state), mood_line=mood_line),
        alert=None,
        alerts=[],
        budget_progress=[],
        threshold_events=[],
        websocket_events=[],
    )


# ── Test 1: Low spend keeps mascot CALM ─────────────────────────
def test_low_spend_mascot_is_calm(monkeypatch) -> None:
    monkeypatch.setattr("app.ai.mascot_engine.llm_json_completion", lambda **_: None)

    mascot = determine_mascot_state(
        MascotInput(
            weekly_percentage_used=25,
            savings_streak_days=3,
            upcoming_bill_due_soon=False,
            weekly_alert_count=0,
            risk_score=15,
        )
    )

    assert mascot.state == MascotState.CALM
    assert mascot.mood_line is not None
    print(f"✅ Mascot state: {mascot.state}")
    print(f"✅ Mood line: {mascot.mood_line}")


# ── Test 2: High spend triggers ALERT ───────────────────────────
def test_high_spend_triggers_alert_state(monkeypatch) -> None:
    monkeypatch.setattr("app.ai.mascot_engine.llm_json_completion", lambda **_: None)

    mascot = determine_mascot_state(
        MascotInput(
            weekly_percentage_used=75,
            savings_streak_days=0,
            upcoming_bill_due_soon=True,
            weekly_alert_count=2,
            risk_score=45,
        )
    )

    assert mascot.state == MascotState.ALERT
    print(f"✅ Mascot state: {mascot.state}")
    print(f"✅ Mood line: {mascot.mood_line}")


# ── Test 3: Over budget triggers PANICKED ───────────────────────
def test_over_budget_triggers_panicked(monkeypatch) -> None:
    monkeypatch.setattr("app.ai.mascot_engine.llm_json_completion", lambda **_: None)

    mascot = determine_mascot_state(
        MascotInput(
            weekly_percentage_used=110,
            savings_streak_days=0,
            upcoming_bill_due_soon=False,
            weekly_alert_count=3,
            risk_score=80,
        )
    )

    assert mascot.state == MascotState.PANICKED
    print(f"✅ Mascot state: {mascot.state}")
    print(f"✅ Mood line: {mascot.mood_line}")


# ── Test 4: Long streak triggers CELEBRATING ────────────────────
def test_long_streak_triggers_celebrating(monkeypatch) -> None:
    monkeypatch.setattr("app.ai.mascot_engine.llm_json_completion", lambda **_: None)

    mascot = determine_mascot_state(
        MascotInput(
            weekly_percentage_used=30,
            savings_streak_days=10,
            upcoming_bill_due_soon=False,
            weekly_alert_count=0,
            risk_score=15,
        )
    )

    assert mascot.state == MascotState.CELEBRATING
    print(f"✅ Mascot state: {mascot.state}")
    print(f"✅ Mood line: {mascot.mood_line}")


# ── Test 5: AI fallback returns safe mood line ──────────────────
def test_ai_failure_falls_back_to_safe_mood_line(monkeypatch) -> None:
    # Simulate Claude being down
    monkeypatch.setattr("app.ai.mascot_engine.llm_json_completion", lambda **_: None)

    mascot = determine_mascot_state(
        MascotInput(
            weekly_percentage_used=60,
            savings_streak_days=0,
            upcoming_bill_due_soon=False,
            weekly_alert_count=1,
            risk_score=42,
        )
    )

    # Should still return a valid response even without AI
    assert mascot.state is not None
    assert mascot.mood_line is not None
    assert len(mascot.mood_line) > 0
    print(f"✅ Fallback mood line: {mascot.mood_line}")


# ── Test 6: Transaction router returns correct JSON shape ────────
def test_transaction_router_response_shape(monkeypatch) -> None:
    monkeypatch.setattr("app.ai.mascot_engine.llm_json_completion", lambda **_: None)

    from app.routers import auth as auth_module
    app.dependency_overrides[auth_module.get_current_user] = lambda: {"id": "u-1"}

    original_service = transactions_router_module.transaction_service

    class _StubTransactionService:
        async def process_transaction(self, payload):
            return _make_response("calm", "Nice and chill. You are tracking well.")

        def list_transactions(self, user_id, limit=30):
            from app.schemas.transaction import TransactionsListResponse
            return TransactionsListResponse(items=[_make_transaction()])

    transactions_router_module.transaction_service = _StubTransactionService()

    try:
        client = TestClient(app)
        res = client.post(
            "/api/transactions",
            json={
                "user_id": "u-1",
                "amount": 45.00,
                "merchant": "GrabFood",
                "category": "FOOD",
                "source": "MANUAL",
                "is_bnpl": False,
            },
            headers={"Authorization": "Bearer test-token"},
        )
    finally:
        transactions_router_module.transaction_service = original_service
        app.dependency_overrides.clear()

    assert res.status_code == 200
    payload = res.json()
    assert "mascot" in payload
    assert "transaction" in payload
    assert "risk_score" in payload
    assert "classification" in payload
    assert payload["mascot"]["state"] in ["calm", "alert", "panicked", "celebrating"]
    print(f"✅ Response shape valid")
    print(f"✅ Mascot state: {payload['mascot']['state']}")
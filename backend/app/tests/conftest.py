import pytest
from app.main import app
from app.routers import auth as auth_module


@pytest.fixture(autouse=True)
def override_auth():
    app.dependency_overrides[auth_module.get_current_user] = lambda: {"id": "00000000-0000-0000-0000-000000000001"}
    yield
    app.dependency_overrides.clear()


@pytest.fixture
def auth_headers():
    return {"Authorization": "Bearer test-token"}


@pytest.fixture
def auth_headers_2():
    return {"Authorization": "Bearer test-token-2"}


@pytest.fixture
def invite_code():
    return "TESTCODE"


@pytest.fixture
def squad_id():
    return "squad-test-1"
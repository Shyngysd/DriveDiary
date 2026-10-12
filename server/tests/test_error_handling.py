import pytest
import re
from fastapi import APIRouter
from fastapi.testclient import TestClient

from main import create_app
from repositories.json_repo import JsonTripRepository, StorageDataError


def test_invalid_date_has_dedicated_error_code(tmp_path) -> None:
    client = TestClient(create_app(JsonTripRepository(tmp_path / "trips.json")))

    response = client.get("/trips?date=not-a-date")

    assert response.status_code == 422
    assert response.json() == {
        "error": {
            "code": "invalid_date",
            "message": "date must be in YYYY-MM-DD format",
        }
    }


def test_validation_error_contains_field_details(tmp_path) -> None:
    client = TestClient(create_app(JsonTripRepository(tmp_path / "trips.json")))

    response = client.post(
        "/trips",
        json={
            "id": "invalid",
            "start": "2026-10-01T08:10:00+05:00",
            "end": "2026-10-01T08:32:00+05:00",
            "amount": 0,
            "payment": "cash",
            "commission": 0,
        },
    )

    assert response.status_code == 422
    assert response.json()["error"]["details"][0]["field"] == "amount"


def test_unhandled_exception_has_safe_500_envelope(tmp_path) -> None:
    app = create_app(JsonTripRepository(tmp_path / "trips.json"))
    router = APIRouter()

    @router.get("/explode")
    def explode() -> None:
        raise RuntimeError("secret internal details")

    app.include_router(router)
    client = TestClient(app, raise_server_exceptions=False)

    response = client.get("/explode")

    assert response.status_code == 500
    assert response.json() == {
        "error": {
            "code": "internal_error",
            "message": "Внутренняя ошибка сервера",
        }
    }
    assert "secret" not in response.text


def test_corrupt_storage_fails_at_startup_with_path(tmp_path) -> None:
    path = tmp_path / "trips.json"
    path.write_text("{not json", encoding="utf-8")

    with pytest.raises(StorageDataError, match=re.escape(str(path))):
        JsonTripRepository(path)

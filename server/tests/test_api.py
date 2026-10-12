from fastapi.testclient import TestClient

from main import create_app
from repositories.json_repo import JsonTripRepository


def client(tmp_path) -> TestClient:
    return TestClient(create_app(JsonTripRepository(tmp_path / "trips.json")))


def trip_payload(trip_id: str = "api-trip") -> dict[str, object]:
    return {
        "id": trip_id,
        "start": "2026-10-06T08:10:00+05:00",
        "end": "2026-10-06T08:32:00+05:00",
        "amount": 1000,
        "payment": "cash",
        "commission": 100,
    }


def test_list_trips_is_sorted_and_summary_is_returned(tmp_path) -> None:
    api = client(tmp_path)
    api.post(
        "/trips",
        json={
            "id": "later",
            "start": "2026-10-01T10:00:00+05:00",
            "end": "2026-10-01T10:20:00+05:00",
            "amount": 200,
            "payment": "card",
            "commission": 20,
        },
    )
    api.post(
        "/trips",
        json={
            "id": "earlier",
            "start": "2026-10-01T08:00:00+05:00",
            "end": "2026-10-01T08:20:00+05:00",
            "amount": 100,
            "payment": "cash",
            "commission": 10,
        },
    )

    trips = api.get("/trips?date=2026-10-01")
    assert trips.status_code == 200
    assert [trip["id"] for trip in trips.json()] == ["earlier", "later"]
    assert api.get("/summary?date=2026-10-01").json() == {
        "trips_count": 2,
        "revenue": 300,
        "commission": 30,
        "net": 270,
        "cash_total": 100,
        "card_total": 200,
    }


def test_days_are_sorted_and_empty_day_is_valid(tmp_path) -> None:
    api = client(tmp_path)
    api.post("/trips", json=trip_payload())

    assert api.get("/days").json() == ["2026-10-06"]
    assert api.get("/trips?date=2026-10-07").json() == []
    assert api.get("/summary?date=2026-10-07").json()["trips_count"] == 0


def test_post_returns_created_then_idempotent_then_conflict(tmp_path) -> None:
    api = client(tmp_path)
    payload = trip_payload()

    assert api.post("/trips", json=payload).status_code == 201
    assert api.post("/trips", json=payload).status_code == 200
    payload["amount"] = 1100
    conflict = api.post("/trips", json=payload)
    assert conflict.status_code == 409
    assert conflict.json()["error"]["code"] == "duplicate_conflict"


def test_validation_and_query_date_errors_use_error_envelope(tmp_path) -> None:
    api = client(tmp_path)
    invalid = trip_payload()
    invalid["start"] = "2026-10-06T08:10:00"

    response = api.post("/trips", json=invalid)
    assert response.status_code == 422
    assert set(response.json()["error"]) == {"code", "message", "details"}
    assert response.json()["error"]["details"]

    response = api.get("/trips?date=not-a-date")
    assert response.status_code == 422
    assert response.json()["error"]["code"] == "invalid_date"


def test_health_and_cors(tmp_path) -> None:
    api = client(tmp_path)

    assert api.get("/health").json() == {"status": "ok"}
    response = api.options(
        "/trips",
        headers={
            "Origin": "http://localhost:3000",
            "Access-Control-Request-Method": "GET",
        },
    )
    assert response.status_code == 200
    assert response.headers["access-control-allow-origin"] == "*"

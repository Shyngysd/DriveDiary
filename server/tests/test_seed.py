import json
import shutil
from datetime import date
from pathlib import Path

from fastapi.testclient import TestClient

from main import create_app
from repositories.json_repo import JsonTripRepository
from services.summary import build_summary


SERVER_ROOT = Path(__file__).resolve().parents[1]
SEED_PATH = SERVER_ROOT / "data" / "seed.json"


def seed_copy(tmp_path: Path) -> Path:
    path = tmp_path / "trips.json"
    shutil.copyfile(SEED_PATH, path)
    return path


def test_seed_reference_trips_and_summary(tmp_path: Path) -> None:
    seed = json.loads(SEED_PATH.read_text(encoding="utf-8"))
    trips = {trip["id"]: trip for trip in seed}

    assert trips["t1"] == {
        "id": "t1",
        "start": "2026-10-01T08:10:00+05:00",
        "end": "2026-10-01T08:32:00+05:00",
        "amount": 2400,
        "payment": "card",
        "commission": 360,
    }
    assert trips["t2"] == {
        "id": "t2",
        "start": "2026-10-01T09:05:00+05:00",
        "end": "2026-10-01T09:20:00+05:00",
        "amount": 1500,
        "payment": "cash",
        "commission": 225,
    }

    repository = JsonTripRepository(seed_copy(tmp_path))
    summary = build_summary(repository.list_by_date(date(2026, 10, 1)))
    assert summary.model_dump() == {
        "trips_count": 2,
        "revenue": 3900,
        "commission": 585,
        "net": 3315,
        "cash_total": 1500,
        "card_total": 2400,
    }


def test_seed_days_and_midnight_trip(tmp_path: Path) -> None:
    client = TestClient(create_app(JsonTripRepository(seed_copy(tmp_path))))

    assert client.get("/days").json() == [
        "2026-10-01",
        "2026-10-02",
        "2026-10-04",
        "2026-10-05",
    ]
    assert [
        trip["id"] for trip in client.get("/trips?date=2026-10-04").json()
    ] == ["day4-a", "day4-midnight"]

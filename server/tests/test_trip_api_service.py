from datetime import datetime, timedelta, timezone

from models.trip import Trip
from services.trip_api import (
    parse_trip_date,
    sort_trips_by_start,
    trip_status_code,
)


def make_trip(trip_id: str, hour: int) -> Trip:
    start = datetime(2026, 10, 1, hour, tzinfo=timezone(timedelta(hours=5)))
    return Trip(
        id=trip_id,
        start=start,
        end=start + timedelta(minutes=20),
        amount=100,
        payment="cash",
        commission=10,
    )


def test_parse_trip_date_and_reject_invalid_format() -> None:
    assert parse_trip_date("2026-10-01").isoformat() == "2026-10-01"

    try:
        parse_trip_date("01.10.2026")
    except ValueError as error:
        assert str(error) == "date must be in YYYY-MM-DD format"
    else:
        raise AssertionError("invalid date was accepted")


def test_sort_and_status_helpers() -> None:
    trips = sort_trips_by_start([make_trip("late", 10), make_trip("early", 8)])

    assert [trip.id for trip in trips] == ["early", "late"]
    assert trip_status_code(True) == 201
    assert trip_status_code(False) == 200

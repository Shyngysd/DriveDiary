from datetime import datetime, timedelta, timezone

import pytest

from models.trip import Trip
from services.day import local_date
from services.summary import build_summary


PLUS_FIVE = timezone(timedelta(hours=5))


def make_trip(
    trip_id: str,
    start: datetime,
    amount: int,
    payment: str,
    commission: int,
) -> Trip:
    return Trip(
        id=trip_id,
        start=start,
        end=start + timedelta(minutes=20),
        amount=amount,
        payment=payment,
        commission=commission,
    )


def test_reference_summary() -> None:
    trips = [
        make_trip("t1", datetime(2026, 10, 1, 8, 10, tzinfo=PLUS_FIVE), 1500, "cash", 225),
        make_trip("t2", datetime(2026, 10, 1, 9, 0, tzinfo=PLUS_FIVE), 2400, "card", 360),
    ]

    assert build_summary(trips).model_dump() == {
        "trips_count": 2,
        "revenue": 3900,
        "commission": 585,
        "net": 3315,
        "cash_total": 1500,
        "card_total": 2400,
    }


def test_empty_day() -> None:
    assert build_summary([]).model_dump() == {
        "trips_count": 0,
        "revenue": 0,
        "commission": 0,
        "net": 0,
        "cash_total": 0,
        "card_total": 0,
    }


def test_cash_only() -> None:
    assert build_summary(
        [make_trip("cash", datetime(2026, 10, 1, 8, 0, tzinfo=PLUS_FIVE), 1500, "cash", 100)]
    ).cash_total == 1500


def test_card_only() -> None:
    assert build_summary(
        [make_trip("card", datetime(2026, 10, 1, 8, 0, tzinfo=PLUS_FIVE), 2400, "card", 200)]
    ).card_total == 2400


def test_late_trip_belongs_to_its_local_start_date() -> None:
    trip = make_trip(
        "late",
        datetime(2026, 10, 1, 23, 50, tzinfo=PLUS_FIVE),
        1000,
        "cash",
        100,
    )

    assert local_date(trip).isoformat() == "2026-10-01"


def test_trips_from_different_days_are_not_mixed() -> None:
    trips = [
        make_trip("day-one", datetime(2026, 10, 1, 23, 50, tzinfo=PLUS_FIVE), 1000, "cash", 100),
        make_trip("day-two", datetime(2026, 10, 2, 0, 10, tzinfo=PLUS_FIVE), 2000, "card", 200),
    ]

    with pytest.raises(ValueError, match="same local day"):
        build_summary(trips)

from datetime import datetime, timezone

import pytest
from pydantic import ValidationError

from models.trip import Trip


def trip_data() -> dict[str, object]:
    return {
        "id": "t1",
        "start": datetime(2026, 10, 1, 8, 10, tzinfo=timezone.utc),
        "end": datetime(2026, 10, 1, 8, 32, tzinfo=timezone.utc),
        "amount": 1000,
        "payment": "cash",
        "commission": 150,
    }


@pytest.mark.parametrize("amount", [0, -1])
def test_amount_must_be_positive(amount: int) -> None:
    data = trip_data()
    data["amount"] = amount

    with pytest.raises(ValidationError):
        Trip.model_validate(data)


@pytest.mark.parametrize(
    ("start", "end"),
    [
        (
            datetime(2026, 10, 1, 8, 10, tzinfo=timezone.utc),
            datetime(2026, 10, 1, 8, 10, tzinfo=timezone.utc),
        ),
        (
            datetime(2026, 10, 1, 8, 32, tzinfo=timezone.utc),
            datetime(2026, 10, 1, 8, 10, tzinfo=timezone.utc),
        ),
    ],
)
def test_end_must_be_after_start(start: datetime, end: datetime) -> None:
    data = trip_data()
    data["start"] = start
    data["end"] = end

    with pytest.raises(ValidationError):
        Trip.model_validate(data)


@pytest.mark.parametrize("commission", [1001, -1])
def test_commission_must_be_between_zero_and_amount(commission: int) -> None:
    data = trip_data()
    data["commission"] = commission

    with pytest.raises(ValidationError):
        Trip.model_validate(data)


def test_payment_must_be_cash_or_card() -> None:
    data = trip_data()
    data["payment"] = "transfer"

    with pytest.raises(ValidationError):
        Trip.model_validate(data)


def test_start_requires_timezone_offset() -> None:
    data = trip_data()
    data["start"] = datetime(2026, 10, 1, 8, 10)

    with pytest.raises(ValidationError):
        Trip.model_validate(data)

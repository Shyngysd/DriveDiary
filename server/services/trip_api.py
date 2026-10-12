import re
from datetime import date

from models.trip import Trip


class InvalidDateError(ValueError):
    """Raised when an API date is not a valid YYYY-MM-DD value."""


def parse_trip_date(value: str) -> date:
    if re.fullmatch(r"\d{4}-\d{2}-\d{2}", value) is None:
        raise InvalidDateError("date must be in YYYY-MM-DD format")
    try:
        return date.fromisoformat(value)
    except ValueError as error:
        raise InvalidDateError("date must be in YYYY-MM-DD format") from error


def sort_trips_by_start(trips: list[Trip]) -> list[Trip]:
    return sorted(trips, key=lambda trip: trip.start)


def serialize_trip(trip: Trip) -> dict[str, object]:
    return trip.model_dump(mode="json")


def trip_status_code(created: bool) -> int:
    return 201 if created else 200

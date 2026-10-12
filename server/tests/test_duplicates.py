from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timedelta, timezone

import pytest

from models.trip import Trip
from repositories.json_repo import JsonTripRepository
from services.trips import DuplicateConflict, TripService


def make_trip(amount: int = 1000) -> Trip:
    start = datetime(2026, 10, 1, 8, 10, tzinfo=timezone(timedelta(hours=5)))
    return Trip(
        id="t1",
        start=start,
        end=start + timedelta(minutes=20),
        amount=amount,
        payment="cash",
        commission=100,
    )


def test_repeated_identical_trip_does_not_increase_count(tmp_path) -> None:
    repository = JsonTripRepository(tmp_path / "trips.json")
    service = TripService(repository)
    trip = make_trip()

    assert service.add_trip(trip) == trip
    assert service.add_trip(trip) == trip
    assert len(repository.list_by_date(trip.start.date())) == 1


def test_changed_trip_with_same_id_raises_conflict(tmp_path) -> None:
    service = TripService(JsonTripRepository(tmp_path / "trips.json"))
    service.add_trip(make_trip())

    with pytest.raises(DuplicateConflict):
        service.add_trip(make_trip(amount=1100))


def test_twenty_parallel_identical_adds_create_one_record(tmp_path) -> None:
    path = tmp_path / "trips.json"
    services = [TripService(JsonTripRepository(path)) for _ in range(20)]
    trip = make_trip()

    with ThreadPoolExecutor(max_workers=20) as executor:
        results = list(
            executor.map(
                lambda service: service.add_trip_with_status(trip),
                services,
            )
        )

    assert sum(created for _, created in results) == 1
    assert sum(not created for _, created in results) == 19
    assert JsonTripRepository(path).get_by_id(trip.id) == trip
    assert len(JsonTripRepository(path).list_by_date(trip.start.date())) == 1


def test_parallel_changed_data_raises_conflict(tmp_path) -> None:
    path = tmp_path / "trips.json"
    services = [TripService(JsonTripRepository(path)) for _ in range(20)]
    trips = [make_trip(amount=1000 + index) for index in range(20)]

    with ThreadPoolExecutor(max_workers=20) as executor:
        results = list(
            executor.map(
                lambda item: _add_and_capture(item[0], item[1]),
                zip(services, trips),
            )
        )

    assert sum(result == "created" for result in results) == 1
    assert sum(result == "conflict" for result in results) == 19


def _add_and_capture(service: TripService, trip: Trip) -> str:
    try:
        _, created = service.add_trip_with_status(trip)
        return "created" if created else "repeated"
    except DuplicateConflict:
        return "conflict"


def test_repository_reload_preserves_data(tmp_path) -> None:
    path = tmp_path / "trips.json"
    trip = make_trip()

    JsonTripRepository(path).add(trip)
    reloaded = JsonTripRepository(path)

    assert reloaded.get_by_id(trip.id) == trip
    assert reloaded.list_dates() == [trip.start.date()]

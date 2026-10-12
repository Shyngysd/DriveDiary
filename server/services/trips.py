from models.trip import Trip
from repositories.base import DuplicateConflict, TripRepository
from threading import RLock

__all__ = ["DuplicateConflict", "TripService"]


class TripService:
    def __init__(self, repository: TripRepository) -> None:
        self.repository = repository
        self._lock = RLock()

    def add_trip(self, trip: Trip) -> Trip:
        return self.add_trip_with_status(trip)[0]

    def add_trip_with_status(self, trip: Trip) -> tuple[Trip, bool]:
        with self._lock:
            existing = self.repository.get_by_id(trip.id)
            if existing is not None:
                if existing == trip:
                    return existing, False
                raise DuplicateConflict(f"trip id already exists: {trip.id}")
            return self.repository.add(trip), True

from models.trip import Trip
from repositories.base import DuplicateConflict, TripRepository

__all__ = ["DuplicateConflict", "TripService"]


class TripService:
    def __init__(self, repository: TripRepository) -> None:
        self.repository = repository

    def add_trip(self, trip: Trip) -> Trip:
        return self.add_trip_with_status(trip)[0]

    def add_trip_with_status(self, trip: Trip) -> tuple[Trip, bool]:
        stored_trip, created = self.repository.add_if_absent(trip)
        if not created and stored_trip != trip:
            raise DuplicateConflict(f"trip id already exists: {trip.id}")
        return stored_trip, created

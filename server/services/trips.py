from models.trip import Trip
from repositories.base import DuplicateConflict, TripRepository

__all__ = ["DuplicateConflict", "TripService"]


class TripService:
    def __init__(self, repository: TripRepository) -> None:
        self.repository = repository

    def add_trip(self, trip: Trip) -> Trip:
        return self.repository.add(trip)

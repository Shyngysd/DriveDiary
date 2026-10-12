from abc import ABC, abstractmethod
from datetime import date

from models.trip import Trip


class DuplicateConflict(Exception):
    """Raised when an id is reused with different trip data."""


class TripRepository(ABC):
    @abstractmethod
    def add(self, trip: Trip) -> Trip:
        """Add a trip or return the identical existing trip."""

    @abstractmethod
    def add_if_absent(self, trip: Trip) -> tuple[Trip, bool]:
        """Atomically add a trip and report whether it was created."""

    @abstractmethod
    def get_by_id(self, trip_id: str) -> Trip | None:
        ...

    @abstractmethod
    def list_by_date(self, trip_date: date) -> list[Trip]:
        ...

    @abstractmethod
    def list_dates(self) -> list[date]:
        ...

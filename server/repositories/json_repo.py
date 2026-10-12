import json
import os
import tempfile
from datetime import date
from pathlib import Path
from threading import RLock

from models.trip import Trip
from repositories.base import DuplicateConflict, TripRepository
from services.day import local_date


class JsonTripRepository(TripRepository):
    _locks: dict[Path, RLock] = {}
    _locks_guard = RLock()

    def __init__(self, path: str | Path | None = None) -> None:
        configured_path = path or os.getenv("TRIPS_FILE", "data/trips.json")
        self.path = Path(configured_path).resolve()
        with self._locks_guard:
            self._lock = self._locks.setdefault(self.path, RLock())

    def add(self, trip: Trip) -> Trip:
        stored_trip, _ = self.add_if_absent(trip)
        if stored_trip != trip:
            raise DuplicateConflict(f"trip id already exists: {trip.id}")
        return stored_trip

    def add_if_absent(self, trip: Trip) -> tuple[Trip, bool]:
        with self._lock:
            trips = self._read()
            existing = next((item for item in trips if item.id == trip.id), None)
            if existing is not None:
                return existing, False

            trips.append(trip)
            self._write(trips)
            return trip, True

    def get_by_id(self, trip_id: str) -> Trip | None:
        with self._lock:
            return next((trip for trip in self._read() if trip.id == trip_id), None)

    def list_by_date(self, trip_date: date) -> list[Trip]:
        with self._lock:
            return [trip for trip in self._read() if local_date(trip) == trip_date]

    def list_dates(self) -> list[date]:
        with self._lock:
            return sorted({local_date(trip) for trip in self._read()})

    def _read(self) -> list[Trip]:
        if not self.path.exists():
            return []
        with self.path.open(encoding="utf-8") as file:
            raw_trips = json.load(file)
        return [Trip.model_validate(raw_trip) for raw_trip in raw_trips]

    def _write(self, trips: list[Trip]) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        fd, temporary_name = tempfile.mkstemp(
            dir=self.path.parent,
            prefix=f".{self.path.name}.",
            suffix=".tmp",
        )
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as file:
                json.dump(
                    [trip.model_dump(mode="json") for trip in trips],
                    file,
                    ensure_ascii=False,
                    indent=2,
                )
                file.write("\n")
                file.flush()
                os.fsync(file.fileno())
            os.replace(temporary_name, self.path)
        except BaseException:
            if os.path.exists(temporary_name):
                os.unlink(temporary_name)
            raise

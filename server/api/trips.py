from datetime import date
import re

from fastapi import APIRouter, Request, status
from fastapi.responses import JSONResponse

from models.summary import DaySummary
from models.trip import Trip
from services.summary import build_summary
from services.trips import TripService

router = APIRouter()


def parse_date(value: str) -> date:
    if re.fullmatch(r"\d{4}-\d{2}-\d{2}", value) is None:
        raise ValueError("date must be in YYYY-MM-DD format")
    try:
        return date.fromisoformat(value)
    except ValueError as error:
        raise ValueError("date must be in YYYY-MM-DD format") from error


def serialized_trip(trip: Trip) -> dict[str, object]:
    return trip.model_dump(mode="json")


@router.get("/trips")
def list_trips(request: Request, date: str) -> list[dict[str, object]]:
    trip_date = parse_date(date)
    trips = request.app.state.repository.list_by_date(trip_date)
    return [serialized_trip(trip) for trip in sorted(trips, key=lambda item: item.start)]


@router.get("/summary", response_model=DaySummary)
def summary(request: Request, date: str) -> DaySummary:
    trip_date = parse_date(date)
    return build_summary(request.app.state.repository.list_by_date(trip_date))


@router.get("/days")
def list_days(request: Request) -> list[str]:
    return [trip_date.isoformat() for trip_date in request.app.state.repository.list_dates()]


@router.post("/trips", status_code=status.HTTP_201_CREATED)
def add_trip(request: Request, trip: Trip) -> JSONResponse:
    service: TripService = request.app.state.service
    saved_trip, created = service.add_trip_with_status(trip)
    return JSONResponse(
        status_code=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        content=serialized_trip(saved_trip),
    )

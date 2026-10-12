from fastapi import APIRouter, Request, status
from fastapi.responses import JSONResponse

from models.summary import DaySummary
from models.trip import Trip
from services.summary import build_summary
from services.trip_api import (
    parse_trip_date,
    serialize_trip,
    sort_trips_by_start,
    trip_status_code,
)
from services.trips import TripService

router = APIRouter()


@router.get("/trips")
def list_trips(request: Request, date: str) -> list[dict[str, object]]:
    trip_date = parse_trip_date(date)
    trips = request.app.state.repository.list_by_date(trip_date)
    return [serialize_trip(trip) for trip in sort_trips_by_start(trips)]


@router.get("/summary", response_model=DaySummary)
def summary(request: Request, date: str) -> DaySummary:
    trip_date = parse_trip_date(date)
    return build_summary(request.app.state.repository.list_by_date(trip_date))


@router.get("/days")
def list_days(request: Request) -> list[str]:
    return [trip_date.isoformat() for trip_date in request.app.state.repository.list_dates()]


@router.post("/trips", status_code=status.HTTP_201_CREATED)
def add_trip(request: Request, trip: Trip) -> JSONResponse:
    service: TripService = request.app.state.service
    saved_trip, created = service.add_trip_with_status(trip)
    return JSONResponse(
        status_code=trip_status_code(created),
        content=serialize_trip(saved_trip),
    )

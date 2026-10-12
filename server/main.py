from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware

from api.errors import (
    duplicate_conflict_handler,
    invalid_date_handler,
    unhandled_exception_handler,
    validation_error_handler,
)
from api.trips import router
from repositories.base import DuplicateConflict
from repositories.json_repo import JsonTripRepository
from services.trip_api import InvalidDateError
from services.trips import TripService


def create_app(repository: JsonTripRepository | None = None) -> FastAPI:
    app = FastAPI()
    trip_repository = repository or JsonTripRepository()
    app.state.repository = trip_repository
    app.state.service = TripService(trip_repository)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=False,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.add_exception_handler(DuplicateConflict, duplicate_conflict_handler)
    app.add_exception_handler(RequestValidationError, validation_error_handler)
    app.add_exception_handler(InvalidDateError, invalid_date_handler)
    app.add_exception_handler(Exception, unhandled_exception_handler)
    app.include_router(router)

    @app.get("/health")
    def health() -> dict[str, str]:
        return {"status": "ok"}

    return app


app = create_app()

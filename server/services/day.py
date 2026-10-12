from datetime import date

from models.trip import Trip


def local_date(trip: Trip) -> date:
    return trip.start.date()

from collections.abc import Iterable

from models.summary import DaySummary
from models.trip import Trip
from services.day import local_date


def build_summary(trips: Iterable[Trip]) -> DaySummary:
    trip_list = list(trips)
    dates = {local_date(trip) for trip in trip_list}
    if len(dates) > 1:
        raise ValueError("all trips must belong to the same local day")

    revenue = sum(trip.amount for trip in trip_list)
    commission = sum(trip.commission for trip in trip_list)
    return DaySummary(
        trips_count=len(trip_list),
        revenue=revenue,
        commission=commission,
        net=revenue - commission,
        cash_total=sum(trip.amount for trip in trip_list if trip.payment == "cash"),
        card_total=sum(trip.amount for trip in trip_list if trip.payment == "card"),
    )

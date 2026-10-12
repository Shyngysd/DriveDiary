from pydantic import BaseModel


class DaySummary(BaseModel):
    trips_count: int
    revenue: int
    commission: int
    net: int
    cash_total: int
    card_total: int

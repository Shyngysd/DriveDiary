from datetime import datetime
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field, model_validator


class Trip(BaseModel):
    model_config = ConfigDict(extra="forbid")

    id: str
    start: datetime
    end: datetime
    amount: int = Field(gt=0)
    payment: Literal["cash", "card"]
    commission: int = Field(ge=0)

    @model_validator(mode="after")
    def validate_trip(self) -> "Trip":
        if self.start.utcoffset() is None or self.end.utcoffset() is None:
            raise ValueError("start and end must include a timezone offset")
        if self.end <= self.start:
            raise ValueError("end must be later than start")
        if self.commission > self.amount:
            raise ValueError("commission must not exceed amount")
        return self

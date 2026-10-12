import logging

from fastapi import Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from repositories.base import DuplicateConflict
from services.trip_api import InvalidDateError

logger = logging.getLogger(__name__)


def error_response(
    code: str,
    message: str,
    status_code: int,
    details: object | None = None,
) -> JSONResponse:
    error = {"code": code, "message": message}
    if details is not None:
        error["details"] = details
    return JSONResponse(
        status_code=status_code,
        content={"error": error},
    )


async def duplicate_conflict_handler(
    _request: Request, exception: DuplicateConflict
) -> JSONResponse:
    return error_response("duplicate_conflict", str(exception), 409)


async def validation_error_handler(
    _request: Request, exception: RequestValidationError
) -> JSONResponse:
    details = [
        {
            "field": ".".join(str(part) for part in error["loc"] if part != "body"),
            "message": error["msg"],
        }
        for error in exception.errors()
    ]
    return error_response(
        "validation_error",
        "Некорректные данные запроса",
        422,
        details,
    )


async def invalid_date_handler(
    _request: Request, exception: InvalidDateError
) -> JSONResponse:
    return error_response("invalid_date", str(exception), 422)


async def unhandled_exception_handler(
    _request: Request, exception: Exception
) -> JSONResponse:
    logger.exception("Unhandled server exception", exc_info=exception)
    return error_response("internal_error", "Внутренняя ошибка сервера", 500)

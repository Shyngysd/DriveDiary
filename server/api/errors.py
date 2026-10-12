from fastapi import Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from repositories.base import DuplicateConflict


def error_response(code: str, message: str, status_code: int) -> JSONResponse:
    return JSONResponse(
        status_code=status_code,
        content={"error": {"code": code, "message": message}},
    )


async def duplicate_conflict_handler(
    _request: Request, exception: DuplicateConflict
) -> JSONResponse:
    return error_response("duplicate_conflict", str(exception), 409)


async def validation_error_handler(
    _request: Request, exception: RequestValidationError
) -> JSONResponse:
    return error_response("validation_error", str(exception), 422)


async def value_error_handler(
    _request: Request, exception: ValueError
) -> JSONResponse:
    return error_response("invalid_request", str(exception), 422)

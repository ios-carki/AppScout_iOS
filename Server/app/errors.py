from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException


class APIError(Exception):
    """앱이 받는 공통 에러 형식: {"code": "...", "message": "..."}

    message는 iOS 알럿에 그대로 보여 줄 수 있는 한국어 문장으로 쓴다.
    """

    def __init__(self, status_code: int, code: str, message: str):
        self.status_code = status_code
        self.code = code
        self.message = message


def _body(code: str, message: str) -> dict:
    return {"code": code, "message": message}


def install_error_handlers(app: FastAPI) -> None:
    @app.exception_handler(APIError)
    async def handle_api_error(_: Request, exc: APIError):
        return JSONResponse(status_code=exc.status_code, content=_body(exc.code, exc.message))

    @app.exception_handler(RequestValidationError)
    async def handle_validation_error(_: Request, exc: RequestValidationError):
        # FastAPI 기본 형식({"detail": [...]}) 대신 공통 형식으로 바꾼다.
        first = exc.errors()[0] if exc.errors() else {}
        field = ".".join(str(p) for p in first.get("loc", []) if p not in ("body", "query", "path"))
        message = f"요청 값이 올바르지 않아요. ({field})" if field else "요청 값이 올바르지 않아요."
        return JSONResponse(status_code=422, content=_body("validation_error", message))

    @app.exception_handler(StarletteHTTPException)
    async def handle_http_error(_: Request, exc: StarletteHTTPException):
        code = {404: "not_found", 405: "method_not_allowed"}.get(exc.status_code, "http_error")
        message = "요청한 정보를 찾을 수 없어요." if exc.status_code == 404 else str(exc.detail)
        return JSONResponse(status_code=exc.status_code, content=_body(code, message))

    @app.exception_handler(Exception)
    async def handle_unexpected(_: Request, exc: Exception):
        return JSONResponse(
            status_code=500,
            content=_body("internal_error", "서버에 문제가 생겼어요. 잠시 후 다시 시도해 주세요."),
        )

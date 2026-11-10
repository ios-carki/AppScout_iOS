from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from . import seed
from .config import settings
from .db import Base, SessionLocal, engine
from .errors import install_error_handlers
from .routers import apps, users


@asynccontextmanager
async def lifespan(_: FastAPI):
    # 하루 범위 프로젝트라 마이그레이션 도구(Alembic) 대신 시작 시 테이블을 만든다.
    Base.metadata.create_all(engine)
    settings.media_dir.mkdir(parents=True, exist_ok=True)
    if settings.auto_seed:
        with SessionLocal() as db:
            seed.seed_if_empty(db)
    yield


app = FastAPI(
    title="AppScout API",
    version="1.0.0",
    description="AppScout iOS 복습 프로젝트용 백엔드. 명세는 docs/backend.md 참고.",
    lifespan=lifespan,
)

install_error_handlers(app)
app.include_router(apps.router)
app.include_router(users.router)
# 업로드한 아바타 이미지 제공 (/media/avatars/1.jpg)
app.mount("/media", StaticFiles(directory=settings.media_dir, check_dir=False), name="media")


@app.get("/health", tags=["system"])
def health():
    return {"status": "ok"}

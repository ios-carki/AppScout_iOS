from collections.abc import Iterator

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from .config import settings


class Base(DeclarativeBase):
    pass


def make_engine(url: str):
    if url.startswith("sqlite"):
        # 테스트(TestClient)는 다른 스레드에서 요청을 처리하므로 스레드 검사를 끈다.
        return create_engine(url, connect_args={"check_same_thread": False})
    # MySQL: 끊긴 커넥션 자동 재연결
    return create_engine(url, pool_pre_ping=True, pool_recycle=3600)


engine = make_engine(settings.database_url)
SessionLocal = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)


def get_db() -> Iterator[Session]:
    """요청마다 세션을 열고 끝나면 닫는 FastAPI 의존성"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

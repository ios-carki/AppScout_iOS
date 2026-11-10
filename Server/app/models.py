from datetime import datetime, timezone

from sqlalchemy import JSON, BigInteger, DateTime, Float, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from .db import Base


def utcnow() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


class App(Base):
    """앱 정보. iTunes Search API 결과를 시드해서 채운다. (id = iTunes trackId)"""

    __tablename__ = "apps"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=False)
    name: Mapped[str] = mapped_column(String(255), index=True)
    seller_name: Mapped[str] = mapped_column(String(255))
    icon_url: Mapped[str | None] = mapped_column(String(512))
    primary_genre: Mapped[str] = mapped_column(String(100), index=True)
    average_rating: Mapped[float | None] = mapped_column(Float)
    rating_count: Mapped[int | None] = mapped_column(Integer)
    formatted_price: Mapped[str | None] = mapped_column(String(50))
    description: Mapped[str] = mapped_column(Text)
    version: Mapped[str] = mapped_column(String(50))
    release_notes: Mapped[str | None] = mapped_column(Text)
    screenshot_urls: Mapped[list[str]] = mapped_column(JSON, default=list)
    genres: Mapped[list[str]] = mapped_column(JSON, default=list)
    file_size_bytes: Mapped[int | None] = mapped_column(BigInteger)
    content_rating: Mapped[str | None] = mapped_column(String(20))
    minimum_os_version: Mapped[str | None] = mapped_column(String(20))
    current_version_release_date: Mapped[datetime | None] = mapped_column(DateTime)
    track_view_url: Mapped[str | None] = mapped_column(String(512))


class User(Base):
    """사용자. 인증 없이 id=1 고정 사용자("me")만 사용한다."""

    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(20))
    email: Mapped[str] = mapped_column(String(100))
    avatar_path: Mapped[str | None] = mapped_column(String(255))
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow, onupdate=utcnow)

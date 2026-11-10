"""응답·요청 스키마.

- 필드 이름은 snake_case 그대로 내려준다. (iOS 디코더가 convertFromSnakeCase로 받음)
- 날짜는 iOS JSONDecoder의 .iso8601 전략이 읽을 수 있도록 "2025-10-01T09:00:00Z" 형식으로 고정한다.
  (Python 기본 isoformat은 시간대 표시가 없거나 마이크로초가 붙어서 iOS에서 디코딩에 실패함)
- 입력 검증 규칙은 iOS Domain의 ProfileValidator와 같다.
"""

import re
from datetime import datetime

from pydantic import BaseModel, ConfigDict, field_serializer


def iso8601_z(value: datetime | None) -> str | None:
    return value.strftime("%Y-%m-%dT%H:%M:%SZ") if value else None


class AppSummaryOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    seller_name: str
    icon_url: str | None
    primary_genre: str
    average_rating: float | None
    rating_count: int | None
    formatted_price: str | None


class AppDetailOut(AppSummaryOut):
    description: str
    version: str
    release_notes: str | None
    screenshot_urls: list[str]
    genres: list[str]
    file_size_bytes: int | None
    content_rating: str | None
    minimum_os_version: str | None
    current_version_release_date: datetime | None
    track_view_url: str | None

    @field_serializer("current_version_release_date")
    def _date(self, value: datetime | None) -> str | None:
        return iso8601_z(value)


class AppPageOut(BaseModel):
    total: int
    limit: int
    offset: int
    items: list[AppSummaryOut]


class ProfileOut(BaseModel):
    id: int
    name: str
    email: str
    avatar_url: str | None
    updated_at: datetime

    @field_serializer("updated_at")
    def _date(self, value: datetime) -> str:
        return iso8601_z(value)


class ProfileUpdateIn(BaseModel):
    """PATCH /v1/users/me. 보낸 필드만 바꾼다."""

    name: str | None = None
    email: str | None = None


# MARK: - 검증 규칙 (iOS ProfileValidator와 동일)

NAME_MIN, NAME_MAX = 2, 20
EMAIL_MAX = 100
EMAIL_PATTERN = re.compile(r"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$")


def validate_name(name: str) -> tuple[str | None, str | None]:
    """(정리된 값, 에러 메시지) 반환"""
    trimmed = name.strip()
    if len(trimmed) < NAME_MIN:
        return None, f"이름은 {NAME_MIN}자 이상 입력해 주세요."
    if len(trimmed) > NAME_MAX:
        return None, f"이름은 {NAME_MAX}자 이하로 입력해 주세요."
    return trimmed, None


def validate_email(email: str) -> tuple[str | None, str | None]:
    trimmed = email.strip()
    if not trimmed:
        return None, "이메일을 입력해 주세요."
    if len(trimmed) > EMAIL_MAX:
        return None, f"이메일은 {EMAIL_MAX}자 이하로 입력해 주세요."
    if not EMAIL_PATTERN.match(trimmed):
        return None, "이메일 형식이 올바르지 않아요."
    return trimmed, None

"""시드 데이터.

- `python -m app.seed --refresh`: iTunes Search API에서 앱 정보를 새로 받아 seed/apps.json에 저장하고 DB에 넣는다.
- `python -m app.seed`: 저장된 seed/apps.json을 DB에 넣는다. (네트워크 불필요)
- 서버 시작 시(AUTO_SEED=true) apps 테이블이 비어 있으면 seed/apps.json으로 자동으로 채운다.
"""

import argparse
import json
import logging
from datetime import datetime
from pathlib import Path

import httpx
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from .models import App, User

logger = logging.getLogger("uvicorn.error")

SEED_FILE = Path(__file__).resolve().parent.parent / "seed" / "apps.json"
ITUNES_SEARCH_URL = "https://itunes.apple.com/search"

# 다양한 장르가 섞이도록 고른 검색어
TERMS = [
    "카카오", "토스", "네이버", "배달", "쿠팡", "지도",
    "사진", "음악", "운동", "공부", "여행", "가계부",
    "메모", "notion", "게임", "날씨",
]
PER_TERM = 25

DEFAULT_USER = {"id": 1, "name": "Chris", "email": "chris@example.com"}


def _parse_date(value: str | None) -> datetime | None:
    if not value:
        return None
    try:
        return datetime.strptime(value, "%Y-%m-%dT%H:%M:%SZ")
    except ValueError:
        return None


def _from_itunes(item: dict) -> dict:
    """iTunes 응답 한 건 → 우리 스키마"""
    file_size = item.get("fileSizeBytes")
    genres = item.get("genres", [])
    return {
        "id": item["trackId"],
        "name": item.get("trackName", ""),
        "seller_name": item.get("sellerName") or item.get("artistName", ""),
        "icon_url": item.get("artworkUrl512") or item.get("artworkUrl100"),
        # lang=ko_kr로 받아도 primaryGenreName은 영어라서, 한국어인 genres의 첫 값(주 장르)을 쓴다.
        "primary_genre": genres[0] if genres else item.get("primaryGenreName", ""),
        "average_rating": item.get("averageUserRating"),
        "rating_count": item.get("userRatingCount"),
        "formatted_price": item.get("formattedPrice"),
        "description": item.get("description", ""),
        "version": item.get("version", ""),
        "release_notes": item.get("releaseNotes"),
        "screenshot_urls": item.get("screenshotUrls", []),
        "genres": genres,
        "file_size_bytes": int(file_size) if file_size else None,
        "content_rating": item.get("contentAdvisoryRating") or item.get("trackContentRating"),
        "minimum_os_version": item.get("minimumOsVersion"),
        "current_version_release_date": item.get("currentVersionReleaseDate"),
        "track_view_url": item.get("trackViewUrl"),
    }


def fetch_from_itunes() -> list[dict]:
    apps: dict[int, dict] = {}
    with httpx.Client(timeout=20) as client:
        for term in TERMS:
            response = client.get(
                ITUNES_SEARCH_URL,
                params={"term": term, "country": "kr", "lang": "ko_kr", "entity": "software", "limit": PER_TERM},
            )
            response.raise_for_status()
            for item in response.json().get("results", []):
                if "trackId" in item:
                    apps.setdefault(item["trackId"], _from_itunes(item))
            logger.info("seed: '%s' → 누적 %d개", term, len(apps))
    return sorted(apps.values(), key=lambda a: -(a["rating_count"] or 0))


def save_seed_file(apps: list[dict]) -> None:
    SEED_FILE.parent.mkdir(parents=True, exist_ok=True)
    SEED_FILE.write_text(json.dumps(apps, ensure_ascii=False, indent=1), encoding="utf-8")


def load_seed_file() -> list[dict]:
    if not SEED_FILE.exists():
        return []
    return json.loads(SEED_FILE.read_text(encoding="utf-8"))


def upsert_apps(db: Session, apps: list[dict]) -> int:
    for data in apps:
        values = {**data, "current_version_release_date": _parse_date(data.get("current_version_release_date"))}
        db.merge(App(**values))
    db.commit()
    return len(apps)


def ensure_default_user(db: Session) -> None:
    if db.get(User, DEFAULT_USER["id"]) is None:
        db.add(User(**DEFAULT_USER))
        db.commit()


def seed_if_empty(db: Session) -> None:
    ensure_default_user(db)
    count = db.scalar(select(func.count()).select_from(App)) or 0
    if count > 0:
        return
    apps = load_seed_file()
    if not apps:
        logger.warning("seed: %s 가 없습니다. `python -m app.seed --refresh`로 만들 수 있어요.", SEED_FILE)
        return
    upsert_apps(db, apps)
    logger.info("seed: 앱 %d개를 넣었습니다.", len(apps))


def main() -> None:
    from .db import Base, SessionLocal, engine

    parser = argparse.ArgumentParser(description="AppScout 시드 데이터")
    parser.add_argument("--refresh", action="store_true", help="iTunes에서 새로 받아 seed/apps.json을 덮어씀")
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO)
    if args.refresh:
        apps = fetch_from_itunes()
        save_seed_file(apps)
        print(f"seed/apps.json 저장: {len(apps)}개")
    else:
        apps = load_seed_file()

    Base.metadata.create_all(engine)
    with SessionLocal() as db:
        ensure_default_user(db)
        print(f"DB 반영: {upsert_apps(db, apps)}개")


if __name__ == "__main__":
    main()

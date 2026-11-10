"""API 테스트. SQLite 메모리 DB와 임시 미디어 폴더를 써서 MySQL·Docker 없이 실행된다.

실행: cd Server && .venv/bin/pytest
"""

import os
import tempfile

os.environ["DATABASE_URL"] = "sqlite://"  # 메모리 DB (app 모듈 import 전에 설정해야 함)
os.environ["MEDIA_DIR"] = tempfile.mkdtemp()
os.environ["AUTO_SEED"] = "true"

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.pool import StaticPool

from app import db as db_module

# 메모리 SQLite는 커넥션마다 DB가 따로 생기므로 하나의 커넥션을 공유한다.
db_module.engine = db_module.create_engine(
    "sqlite://", connect_args={"check_same_thread": False}, poolclass=StaticPool
)
db_module.SessionLocal.configure(bind=db_module.engine)

from app import main  # noqa: E402

main.engine = db_module.engine


@pytest.fixture(scope="module")
def client():
    with TestClient(main.app) as c:
        yield c


def test_health(client):
    assert client.get("/health").json() == {"status": "ok"}


def test_search_returns_page(client):
    response = client.get("/v1/apps/search", params={"term": "카카오", "limit": 5})
    assert response.status_code == 200
    body = response.json()
    assert set(body) == {"total", "limit", "offset", "items"}
    assert body["limit"] == 5
    assert 0 < len(body["items"]) <= 5
    first = body["items"][0]
    assert {"id", "name", "seller_name", "icon_url", "primary_genre", "average_rating"} <= set(first)


def test_search_pagination_has_no_overlap(client):
    first = client.get("/v1/apps/search", params={"term": "a", "limit": 3, "offset": 0}).json()
    second = client.get("/v1/apps/search", params={"term": "a", "limit": 3, "offset": 3}).json()
    ids_first = {item["id"] for item in first["items"]}
    ids_second = {item["id"] for item in second["items"]}
    assert ids_first.isdisjoint(ids_second)


def test_search_requires_term(client):
    response = client.get("/v1/apps/search", params={"term": "   "})
    assert response.status_code == 400
    assert response.json()["code"] == "empty_term"


def test_detail_and_date_format(client):
    app_id = client.get("/v1/apps/search", params={"term": "카카오"}).json()["items"][0]["id"]
    detail = client.get(f"/v1/apps/{app_id}").json()
    assert detail["id"] == app_id
    assert isinstance(detail["screenshot_urls"], list)
    date = detail["current_version_release_date"]
    # iOS .iso8601 디코딩 형식: 2025-10-01T09:00:00Z
    assert date is None or (date.endswith("Z") and len(date) == 20)


def test_detail_not_found(client):
    response = client.get("/v1/apps/1")
    assert response.status_code == 404
    assert response.json() == {"code": "app_not_found", "message": "앱 정보를 찾을 수 없어요."}


def test_profile_update_and_validation(client):
    me = client.get("/v1/users/me").json()
    assert me["id"] == 1

    ok = client.patch("/v1/users/me", json={"name": "  철수  "})
    assert ok.status_code == 200
    assert ok.json()["name"] == "철수"
    assert ok.json()["updated_at"].endswith("Z")

    bad_name = client.patch("/v1/users/me", json={"name": "a"})
    assert bad_name.status_code == 422
    assert bad_name.json()["code"] == "invalid_name"

    bad_email = client.patch("/v1/users/me", json={"email": "chris@"})
    assert bad_email.status_code == 422
    assert bad_email.json()["code"] == "invalid_email"


def test_avatar_upload(client):
    jpeg = b"\xff\xd8\xff\xe0" + b"0" * 100
    response = client.put("/v1/users/me/avatar", files={"file": ("a.jpg", jpeg, "image/jpeg")})
    assert response.status_code == 200
    url = response.json()["avatar_url"]
    assert url == "/media/avatars/1.jpg"
    assert client.get(url).content == jpeg

    wrong_type = client.put("/v1/users/me/avatar", files={"file": ("a.gif", b"GIF89a", "image/gif")})
    assert wrong_type.status_code == 415

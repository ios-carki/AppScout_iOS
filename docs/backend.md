# 백엔드 (FastAPI + MySQL)

`Server/` 폴더. 앱 검색·상세와 사용자 프로필을 제공합니다.

## 구성

```
Server/
├── docker-compose.yml   MySQL 8.4 + API 컨테이너
├── Dockerfile           python:3.12-slim + uvicorn
├── .env.example         DB 계정, 포트
├── requirements.txt     FastAPI, SQLAlchemy 2, PyMySQL, Pydantic 2, httpx
├── app/
│   ├── main.py          앱 생성, 시작 시 테이블 생성·자동 시드, /media 정적 파일
│   ├── config.py        환경 변수 (DATABASE_URL, MEDIA_DIR, AUTO_SEED)
│   ├── db.py            SQLAlchemy 엔진·세션
│   ├── models.py        apps, users 테이블
│   ├── schemas.py       응답 스키마, 날짜 형식, 입력 검증 규칙
│   ├── errors.py        공통 에러 형식 {code, message}
│   ├── seed.py          iTunes → seed/apps.json → DB
│   └── routers/         apps.py, users.py
├── seed/apps.json       iTunes에서 받은 앱 약 300개 (커밋됨)
└── tests/test_api.py    pytest (SQLite 메모리 DB)
```

## 실행

```bash
cd Server
cp .env.example .env              # 필요하면 비밀번호·포트 수정
docker compose up -d --build      # MySQL이 healthy가 된 뒤 API 시작
docker compose logs -f api        # "seed: 앱 299개를 넣었습니다." 확인
```

| 주소 | 내용 |
|---|---|
| http://localhost:8000/health | 상태 확인 |
| http://localhost:8000/docs | Swagger UI (요청을 직접 보내 볼 수 있음) |
| localhost:3307 | MySQL (호스트에서 접속할 때. 계정은 `.env`) |

정리:

```bash
docker compose down        # 컨테이너만 정리 (데이터 유지)
docker compose down -v     # DB·업로드 이미지까지 삭제 → 다음 실행 때 다시 시드
```

### Docker 없이 실행

`DATABASE_URL`을 지정하지 않으면 SQLite 파일(`appscout.db`)을 씁니다.

```bash
python3.13 -m venv .venv && .venv/bin/pip install -r requirements-dev.txt
.venv/bin/uvicorn app.main:app --reload
```

> Python 3.14는 고정한 pydantic-core 버전의 휠이 없어서 설치가 실패합니다. 3.12 또는 3.13을 쓰세요.

### 시드 데이터 갱신

```bash
.venv/bin/python -m app.seed --refresh   # iTunes에서 새로 받아 seed/apps.json 덮어쓰기 + DB 반영
.venv/bin/python -m app.seed             # seed/apps.json만 DB에 반영 (네트워크 불필요)
```

- 검색어 16개(카카오, 토스, 네이버, 배달, 게임 등)로 25개씩 받아 중복을 제거합니다.
- `lang=ko_kr`로 받아도 `primaryGenreName`은 영어라서, 한국어인 `genres[0]`을 주 장르로 씁니다.
- Docker로 실행 중인 DB에 다시 넣으려면 `docker compose down -v && docker compose up -d`가 가장 간단합니다.

## iOS 앱에서 접속

| 환경 | 방법 |
|---|---|
| 시뮬레이터 | 그대로 `http://localhost:8000` (기본값) |
| 실기기 | Mac과 같은 Wi-Fi에서 `Configs/Shared.xcconfig`의 `API_HOST`를 Mac IP로 변경 (예: `192.168.0.10:8000`) |

Info.plist에 `NSAllowsLocalNetworking = YES`가 있어서 로컬 네트워크의 http는 ATS 예외로 허용됩니다. 실기기에서 IP로 접속할 때 막히면 `NSExceptionDomains`를 추가하세요.

## 인증

하루 범위 프로젝트라 **인증이 없습니다.** 모든 요청은 `id = 1` 사용자("me")로 처리합니다. 서버가 처음 시작할 때 이 사용자(Chris / chris@example.com)를 만듭니다.

확장 아이디어: `/v1/auth/login`이 JWT를 내려주고, iOS `HTTPClient`에 Alamofire `RequestInterceptor`로 토큰을 붙이고, 401이면 토큰을 갱신합니다.

---

## API 명세

공통:
- 필드 이름은 **snake_case**. iOS는 `keyDecodingStrategy = .convertFromSnakeCase`로 받습니다.
- 날짜는 **`2025-10-01T09:00:00Z`** 형식(UTC, 초 단위, `Z`). iOS `JSONDecoder.dateDecodingStrategy = .iso8601`과 맞춘 형식입니다.
- 에러는 항상 아래 형식입니다. `message`는 알럿에 그대로 써도 되는 문장입니다.

```json
{ "code": "invalid_email", "message": "이메일 형식이 올바르지 않아요." }
```

### `GET /v1/apps/search`

앱 이름·개발사·장르에 검색어가 포함된 앱을 **평가 수가 많은 순**으로 돌려줍니다. 대소문자는 구분하지 않습니다.

| 쿼리 | 타입 | 기본값 | 제약 |
|---|---|---|---|
| `term` | string | (필수) | 1~100자, 공백뿐이면 400 |
| `limit` | int | 20 | 1~50 |
| `offset` | int | 0 | 0 이상 |

```json
{
  "total": 11,
  "limit": 20,
  "offset": 0,
  "items": [
    {
      "id": 362057947,
      "name": "카카오톡 KakaoTalk",
      "seller_name": "Kakao Corp.",
      "icon_url": "https://is1-ssl.mzstatic.com/.../512x512bb.jpg",
      "primary_genre": "소셜 네트워킹",
      "average_rating": 3.56216,
      "rating_count": 941736,
      "formatted_price": "무료"
    }
  ]
}
```

`average_rating`, `rating_count`, `formatted_price`, `icon_url`은 `null`일 수 있습니다. (iOS Mapper가 0 / "무료" / nil로 처리)

다음 페이지가 있는지는 `offset + items.length < total`로 판단합니다.

### `GET /v1/apps/{id}`

검색 결과 항목의 모든 필드에 아래 필드가 더해집니다.

| 필드 | 타입 | 비고 |
|---|---|---|
| `description` | string | |
| `version` | string | |
| `release_notes` | string \| null | 빈 문자열일 수 있음 (iOS에서 nil로 처리) |
| `screenshot_urls` | string[] | 비어 있을 수 있음 |
| `genres` | string[] | 첫 값이 주 장르 |
| `file_size_bytes` | int \| null | |
| `content_rating` | string \| null | "4+", "12+" … |
| `minimum_os_version` | string \| null | |
| `current_version_release_date` | string \| null | ISO8601 `Z` |
| `track_view_url` | string \| null | App Store 주소 |

| 상태 | code |
|---|---|
| 404 | `app_not_found` |

### `GET /v1/users/me`

```json
{
  "id": 1,
  "name": "Chris",
  "email": "chris@example.com",
  "avatar_url": "/media/avatars/1.jpg",
  "updated_at": "2026-11-10T14:47:08Z"
}
```

`avatar_url`은 **상대 경로**이거나 `null`입니다. iOS `ProfileRepositoryImpl`이 base URL과 합치고, 이미지가 바뀌었을 때 캐시가 갱신되도록 `?v={updated_at}`를 붙입니다.

### `PATCH /v1/users/me`

보낸 필드만 바꿉니다.

```json
{ "name": "철수" }
{ "email": "new@example.com" }
```

| 검증 | 규칙 (iOS `ProfileValidator`와 동일) | 실패 시 |
|---|---|---|
| name | 앞뒤 공백 제거 후 2~20자 | 422 `invalid_name` |
| email | 필수, 100자 이하, `^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$` | 422 `invalid_email` |
| 둘 다 없음 | | 400 `empty_update` |

### `PUT /v1/users/me/avatar`

`multipart/form-data`, 필드 이름 `file`.

| 제약 | 실패 시 |
|---|---|
| `image/jpeg` 또는 `image/png` | 415 `unsupported_image_type` |
| 5MB 이하 | 413 `file_too_large` |
| 비어 있지 않음 | 400 `empty_file` |

성공하면 프로필 전체를 돌려줍니다. 파일은 `MEDIA_DIR/avatars/1.jpg`에 저장되고 `/media/avatars/1.jpg`로 제공됩니다.

### 에러 코드 전체

| 상태 | code | 발생 |
|---|---|---|
| 400 | `empty_term`, `empty_update`, `empty_file` | 입력 누락 |
| 404 | `app_not_found`, `user_not_found`, `not_found` | 대상 없음 |
| 413 | `file_too_large` | 업로드 용량 초과 |
| 415 | `unsupported_image_type` | 이미지 형식 |
| 422 | `invalid_name`, `invalid_email`, `validation_error` | 검증 실패 |
| 500 | `internal_error` | 서버 내부 오류 |

iOS에서의 변환 (`Data/Sources/Error/ErrorMapping.swift`):

| HTTP | DomainError |
|---|---|
| 연결 실패·타임아웃 | `.network` |
| 404 | `.notFound` |
| 400, 413, 415, 422 | `.validation(.server(message:))` |
| 그 외 4xx·5xx | `.server(message:)` |
| 디코딩 실패 | `.unknown` |
| 요청 취소 | `CancellationError` (알럿 표시 안 함) |

## 테스트

```bash
cd Server && .venv/bin/pytest
```

SQLite 메모리 DB와 임시 미디어 폴더를 써서 MySQL·Docker 없이 실행됩니다. 검색 페이지네이션, 날짜 형식, 404, 프로필 검증, 아바타 업로드를 확인합니다.

iOS 쪽에서 실제 서버 응답과 DTO가 맞는지는 `Projects/Data/Tests/LiveServerIntegrationTests.swift`가 확인합니다. (`TEST_RUNNER_APPSCOUT_INTEGRATION=1`일 때만 실행)

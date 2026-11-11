# AppScout

TCA(The Composable Architecture) 복습 프로젝트. 앱 검색 · 상세 · 즐겨찾기 · 프로필 편집 · 설정.

- **iOS**: SwiftUI, TCA 1.26, Tuist 모듈 구조 (Feature / Domain / Data / Core / Shared), SQLiteData, Alamofire, Kingfisher
- **Server**: FastAPI + MySQL (Docker Compose), iTunes Search API에서 시드한 앱 데이터

Core·Domain·Data·DesignSystem·서버는 구현되어 있고, **Feature 계층은 뼈대만 있어 직접 구현하는 것이 목표**입니다.

## 빠른 시작

```bash
# 1. 서버
cd Server && cp .env.example .env && docker compose up -d --build && cd ..

# 2. iOS
tuist install && tuist generate
```

## 문서

| | |
|---|---|
| [docs/README.md](docs/README.md) | 전체 안내, 실행·테스트 방법 |
| [docs/feature-guide.md](docs/feature-guide.md) | 기능별 요구사항과 구현 순서 |
| [docs/wireframe/AppScout_Wireframe.pdf](docs/wireframe/AppScout_Wireframe.pdf) | 와이어프레임 & 디자인 스펙 28쪽 (화면별 · 컴포넌트별 레드라인과 레이어 스펙) |
| [docs/lecture-gaps.md](docs/lecture-gaps.md) | 강의 코드와 최신 TCA·SwiftUI의 차이 |
| [docs/architecture.md](docs/architecture.md) | 모듈 구조와 의존성 주입 |
| [docs/local-db.md](docs/local-db.md) | SQLiteData 사용법 |
| [docs/backend.md](docs/backend.md) | 서버 실행과 API 명세 |
| [docs/design-system.md](docs/design-system.md) | 컬러·타이포그래피·컴포넌트 |

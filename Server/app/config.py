from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """환경 변수 설정. docker-compose.yml의 environment 또는 .env에서 읽는다."""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # 로컬에서 Docker 없이 실행하면 SQLite 파일을 쓴다.
    database_url: str = "sqlite:///./appscout.db"
    media_dir: Path = Path("./media")
    # 앱 시작 시 apps 테이블이 비어 있으면 seed/apps.json으로 채운다.
    auto_seed: bool = True
    # 업로드 가능한 아바타 최대 크기 (iOS가 1024px JPEG로 줄여서 보내므로 넉넉함)
    avatar_max_bytes: int = 5 * 1024 * 1024


settings = Settings()

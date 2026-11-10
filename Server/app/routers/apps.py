from fastapi import APIRouter, Depends, Query
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from ..db import get_db
from ..errors import APIError
from ..models import App
from ..schemas import AppDetailOut, AppPageOut, AppSummaryOut

router = APIRouter(prefix="/v1/apps", tags=["apps"])


@router.get("/search", response_model=AppPageOut)
def search_apps(
    term: str = Query(..., min_length=1, max_length=100, description="검색어 (앱 이름, 개발사, 장르)"),
    limit: int = Query(20, ge=1, le=50),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
):
    """앱 이름·개발사·장르에 검색어가 포함된 앱을 평가 수 많은 순으로 돌려준다."""
    keyword = term.strip()
    if not keyword:
        raise APIError(400, "empty_term", "검색어를 입력해 주세요.")

    pattern = f"%{keyword.lower()}%"
    condition = or_(
        func.lower(App.name).like(pattern),
        func.lower(App.seller_name).like(pattern),
        func.lower(App.primary_genre).like(pattern),
    )
    total = db.scalar(select(func.count()).select_from(App).where(condition)) or 0
    rows = db.scalars(
        select(App)
        .where(condition)
        .order_by(App.rating_count.desc(), App.id)
        .limit(limit)
        .offset(offset)
    ).all()
    return AppPageOut(
        total=total,
        limit=limit,
        offset=offset,
        items=[AppSummaryOut.model_validate(row) for row in rows],
    )


@router.get("/{app_id}", response_model=AppDetailOut)
def get_app(app_id: int, db: Session = Depends(get_db)):
    app = db.get(App, app_id)
    if app is None:
        raise APIError(404, "app_not_found", "앱 정보를 찾을 수 없어요.")
    return AppDetailOut.model_validate(app)

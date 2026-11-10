from fastapi import APIRouter, Depends, File, UploadFile
from sqlalchemy.orm import Session

from ..config import settings
from ..db import get_db
from ..errors import APIError
from ..models import User, utcnow
from ..schemas import ProfileOut, ProfileUpdateIn, validate_email, validate_name

router = APIRouter(prefix="/v1/users", tags=["users"])

# 인증이 없으므로 항상 id=1 사용자를 "나"로 취급한다. (docs/backend.md 참고)
ME_ID = 1
ALLOWED_IMAGE_TYPES = {"image/jpeg": "jpg", "image/png": "png"}


def _me(db: Session) -> User:
    user = db.get(User, ME_ID)
    if user is None:
        raise APIError(404, "user_not_found", "사용자 정보를 찾을 수 없어요.")
    return user


def _to_out(user: User) -> ProfileOut:
    return ProfileOut(
        id=user.id,
        name=user.name,
        email=user.email,
        avatar_url=f"/media/{user.avatar_path}" if user.avatar_path else None,
        updated_at=user.updated_at,
    )


@router.get("/me", response_model=ProfileOut)
def get_me(db: Session = Depends(get_db)):
    return _to_out(_me(db))


@router.patch("/me", response_model=ProfileOut)
def update_me(body: ProfileUpdateIn, db: Session = Depends(get_db)):
    user = _me(db)
    if body.name is None and body.email is None:
        raise APIError(400, "empty_update", "변경할 항목이 없어요.")

    if body.name is not None:
        name, error = validate_name(body.name)
        if error:
            raise APIError(422, "invalid_name", error)
        user.name = name

    if body.email is not None:
        email, error = validate_email(body.email)
        if error:
            raise APIError(422, "invalid_email", error)
        user.email = email

    user.updated_at = utcnow()
    db.commit()
    return _to_out(user)


@router.put("/me/avatar", response_model=ProfileOut)
async def upload_avatar(file: UploadFile = File(...), db: Session = Depends(get_db)):
    extension = ALLOWED_IMAGE_TYPES.get(file.content_type or "")
    if extension is None:
        raise APIError(415, "unsupported_image_type", "JPEG 또는 PNG 이미지만 올릴 수 있어요.")

    data = await file.read()
    if not data:
        raise APIError(400, "empty_file", "이미지를 선택해 주세요.")
    if len(data) > settings.avatar_max_bytes:
        mb = settings.avatar_max_bytes // 1024 // 1024
        raise APIError(413, "file_too_large", f"이미지는 {mb}MB 이하만 올릴 수 있어요.")

    user = _me(db)
    relative = f"avatars/{user.id}.{extension}"
    target = settings.media_dir / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(data)

    user.avatar_path = relative
    user.updated_at = utcnow()
    db.commit()
    return _to_out(user)

"""Authentication service helpers."""

from __future__ import annotations

import uuid
from datetime import UTC, datetime
from typing import Any

import redis.asyncio as aioredis
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.exceptions import AuthInvalidTokenError
from app.core.security import create_access_token, create_refresh_token, verify_firebase_token, verify_jwt
from app.models.user import UserModel
from app.schemas.auth import TokenResponseSchema


def _normalize_auth_provider(provider: str | None) -> str:
    if provider in ("google.com", "google"):
        return "google"
    if provider in ("anonymous", None, ""):
        return "anonymous"
    return provider.split(".")[0]


async def get_or_create_user(firebase_claims: dict[str, Any], db: AsyncSession) -> UserModel:
    """Find or create a user based on Firebase claims."""
    firebase_uid = firebase_claims.get("uid")
    if not firebase_uid:
        raise AuthInvalidTokenError()

    result = await db.execute(select(UserModel).where(UserModel.firebase_uid == firebase_uid))
    user = result.scalar_one_or_none()

    firebase_dict = firebase_claims.get("firebase")
    sign_in_provider = None
    if isinstance(firebase_dict, dict):
        sign_in_provider = firebase_dict.get("sign_in_provider")
    auth_provider = _normalize_auth_provider(sign_in_provider)
    email = firebase_claims.get("email")
    display_name = firebase_claims.get("name")
    photo_url = firebase_claims.get("picture")
    last_login_at = datetime.now(UTC)

    if user is not None:
        user.email = email
        user.display_name = display_name
        user.photo_url = photo_url
        user.auth_provider = auth_provider
        user.last_login_at = last_login_at
        await db.commit()
        await db.refresh(user)
        return user

    user = UserModel(
        firebase_uid=firebase_uid,
        email=email,
        display_name=display_name,
        photo_url=photo_url,
        auth_provider=auth_provider,
        tier="free",
        last_login_at=last_login_at,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


async def exchange_token(firebase_token: str, db: AsyncSession) -> TokenResponseSchema:
    """Exchange Firebase token for backend JWTs."""
    firebase_claims = await verify_firebase_token(firebase_token)
    user = await get_or_create_user(firebase_claims, db)

    access_token = create_access_token(
        {
            "user_id": str(user.id),
            "tier": user.tier,
            "auth_method": user.auth_provider,
        }
    )
    refresh_token = create_refresh_token(str(user.id))

    settings = get_settings()
    return TokenResponseSchema(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )


async def refresh_tokens(
    refresh_token: str,
    db: AsyncSession,
    redis: aioredis.Redis,
) -> TokenResponseSchema:
    """Rotate refresh tokens and issue a new access token."""
    payload = verify_jwt(refresh_token)
    if payload.get("type") != "refresh":
        raise AuthInvalidTokenError()

    jti = payload.get("jti")
    if not jti:
        raise AuthInvalidTokenError()

    used_key = f"refresh_token:{jti}"
    settings = get_settings()
    is_new = await redis.set(
        used_key,
        "used",
        ex=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS * 24 * 60 * 60,
        nx=True,
    )
    if not is_new:
        raise AuthInvalidTokenError()

    user_id = payload.get("sub")
    if not user_id:
        raise AuthInvalidTokenError()

    try:
        user_uuid = uuid.UUID(str(user_id))
    except ValueError as exc:
        raise AuthInvalidTokenError() from exc

    result = await db.execute(select(UserModel).where(UserModel.id == user_uuid))
    user = result.scalar_one_or_none()
    if user is None:
        raise AuthInvalidTokenError()

    access_token = create_access_token(
        {
            "user_id": str(user.id),
            "tier": user.tier,
            "auth_method": user.auth_provider,
        }
    )
    new_refresh_token = create_refresh_token(str(user.id))

    return TokenResponseSchema(
        access_token=access_token,
        refresh_token=new_refresh_token,
        token_type="bearer",
        expires_in=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )

"""Security helpers for Firebase and JWT handling."""

from __future__ import annotations

import asyncio
import logging
import uuid
from datetime import UTC, datetime, timedelta
from typing import Any

import firebase_admin
import jwt
from firebase_admin import auth as firebase_auth
from firebase_admin import credentials

from app.core.config import Settings, get_settings
from app.core.exceptions import AuthInvalidTokenError, AuthProviderTokenInvalidError

logger = logging.getLogger(__name__)


def init_firebase(settings: Settings) -> None:
    """Initialize Firebase Admin SDK."""
    if firebase_admin._apps:
        return

    if settings.FIREBASE_SERVICE_ACCOUNT_PATH:
        cred = credentials.Certificate(settings.FIREBASE_SERVICE_ACCOUNT_PATH)
        firebase_admin.initialize_app(cred)
        logger.info("Firebase Admin SDK initialized with service account")
        return

    if settings.FIREBASE_PROJECT_ID:
        firebase_admin.initialize_app(options={"projectId": settings.FIREBASE_PROJECT_ID})
        logger.info("Firebase Admin SDK initialized with project ID")
        return

    logger.warning("No Firebase credentials configured - auth endpoints will fail")


async def verify_firebase_token(token: str) -> dict[str, Any]:
    """Verify Firebase ID token and return decoded claims."""
    try:
        decoded = await asyncio.to_thread(
            firebase_auth.verify_id_token,
            token,
            check_revoked=True,
            clock_skew_seconds=5,
        )
    except Exception as exc:
        logger.warning(f"Firebase token verification failed: {exc}")
        raise AuthProviderTokenInvalidError() from exc
    return decoded


def create_access_token(data: dict[str, Any]) -> str:
    """Create a signed access token for the user."""
    settings = get_settings()
    issued_at = datetime.now(UTC)
    expires_at = issued_at + timedelta(minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES)

    payload = {
        "sub": str(data["user_id"]),
        "user_id": str(data["user_id"]),
        "tier": data["tier"],
        "auth_method": data["auth_method"],
        "jti": uuid.uuid4().hex,
        "type": "access",
        "iat": int(issued_at.timestamp()),
        "exp": int(expires_at.timestamp()),
    }

    return jwt.encode(
        payload,
        settings.JWT_SECRET_KEY.get_secret_value(),
        algorithm=settings.JWT_ALGORITHM,
    )


def create_refresh_token(user_id: str) -> str:
    """Create a signed refresh token for the user."""
    settings = get_settings()
    issued_at = datetime.now(UTC)
    expires_at = issued_at + timedelta(days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS)

    payload = {
        "sub": str(user_id),
        "jti": uuid.uuid4().hex,
        "type": "refresh",
        "iat": int(issued_at.timestamp()),
        "exp": int(expires_at.timestamp()),
    }

    return jwt.encode(
        payload,
        settings.JWT_SECRET_KEY.get_secret_value(),
        algorithm=settings.JWT_ALGORITHM,
    )


def verify_jwt(token: str) -> dict[str, Any]:
    """Decode and validate a backend JWT."""
    settings = get_settings()
    try:
        return jwt.decode(
            token,
            settings.JWT_SECRET_KEY.get_secret_value(),
            algorithms=[settings.JWT_ALGORITHM],
        )
    except jwt.ExpiredSignatureError as exc:
        raise AuthInvalidTokenError() from exc
    except jwt.InvalidTokenError as exc:
        raise AuthInvalidTokenError() from exc

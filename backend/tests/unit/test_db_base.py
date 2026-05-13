"""Unit tests for SQLAlchemy base configuration."""

from sqlalchemy import DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.ext.asyncio import AsyncEngine, AsyncSession, async_sessionmaker

from app.core.config import get_settings
from app.db.base import AsyncSessionLocal, Base, async_engine


def test_async_engine_uses_settings_url():
    """Ensure the async engine uses the configured database URL."""
    settings = get_settings()
    engine_url = async_engine.url.render_as_string(hide_password=False)
    assert engine_url == settings.DATABASE_URL
    assert isinstance(async_engine, AsyncEngine)


def test_async_session_factory_configuration():
    """Ensure the async session factory targets AsyncSession and the configured engine."""
    assert isinstance(AsyncSessionLocal, async_sessionmaker)
    assert AsyncSessionLocal.class_ is AsyncSession
    bind = getattr(AsyncSessionLocal, "bind", None) or AsyncSessionLocal.kw.get("bind")
    assert bind is async_engine


def test_base_model_has_standard_fields():
    """Ensure the base model includes id, created_at, and updated_at columns."""

    class ExampleModel(Base):
        """Example model for testing base columns."""

        __tablename__ = "examples"

    columns = ExampleModel.__table__.columns

    assert "id" in columns
    assert "created_at" in columns
    assert "updated_at" in columns

    id_column = columns["id"]
    created_at_column = columns["created_at"]
    updated_at_column = columns["updated_at"]

    assert isinstance(id_column.type, UUID)
    assert isinstance(created_at_column.type, DateTime)
    assert isinstance(updated_at_column.type, DateTime)
    assert created_at_column.type.timezone is True
    assert updated_at_column.type.timezone is True

    assert id_column.server_default is not None
    assert created_at_column.server_default is not None
    assert updated_at_column.server_default is not None

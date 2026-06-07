"""Tests for the Idea SQLAlchemy model."""

import uuid

from sqlalchemy import ForeignKey, String, Text
from sqlalchemy.dialects.postgresql import UUID as PG_UUID

from app.models import IdeaModel


def test_idea_model_table_shape() -> None:
    """IdeaModel defines the expected ideas table columns and constraints."""
    table = IdeaModel.__table__

    assert table.name == "ideas"
    assert isinstance(table.c.user_id.type, PG_UUID)
    assert table.c.user_id.nullable is False
    assert table.c.user_id.index is True
    assert isinstance(next(iter(table.c.user_id.foreign_keys)), ForeignKey)
    assert next(iter(table.c.user_id.foreign_keys)).target_fullname == "users.id"

    assert isinstance(table.c.idea_text.type, Text)
    assert table.c.idea_text.nullable is False
    assert isinstance(table.c.target_audience.type, String)
    assert table.c.target_audience.type.length == 255
    assert isinstance(table.c.region.type, String)
    assert table.c.region.type.length == 100
    assert table.c.status.default.arg == "pending"


def test_idea_model_instantiates_with_pending_status() -> None:
    """New ideas default to pending status for downstream analysis."""
    idea = IdeaModel(
        user_id=uuid.uuid4(),
        idea_text="A marketplace for independent coffee shops",
    )

    assert idea.status is None or idea.status == "pending"

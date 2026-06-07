"""
create ideas table

Revision ID: db34530b5f9b
Revises: b3a5c2e1b9af
Create Date: 2026-06-07 02:31:16.737682
"""

from __future__ import annotations

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

# Revision identifiers, used by Alembic.
revision: str = "db34530b5f9b"
down_revision: str | None = "b3a5c2e1b9af"
branch_labels: str | None = None
depends_on: str | None = None


def upgrade() -> None:
    """Run upgrade migrations."""
    op.create_table(
        "ideas",
        sa.Column(
            "id",
            postgresql.UUID(as_uuid=True),
            primary_key=True,
            server_default=sa.text("gen_random_uuid()"),
            nullable=False,
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=False,
        ),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("idea_text", sa.Text(), nullable=False),
        sa.Column("target_audience", sa.String(length=255), nullable=True),
        sa.Column("industry", sa.String(length=255), nullable=True),
        sa.Column("monetization_model", sa.String(length=255), nullable=True),
        sa.Column("region", sa.String(length=100), nullable=True),
        sa.Column("status", sa.String(length=20), nullable=False, server_default="pending"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
    )
    op.create_index("ix_ideas_user_id", "ideas", ["user_id"], unique=False)


def downgrade() -> None:
    """Run downgrade migrations."""
    op.drop_index("ix_ideas_user_id", table_name="ideas")
    op.drop_table("ideas")

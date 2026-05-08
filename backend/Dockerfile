# =============================================================================
# VentureIQ Backend Dockerfile
# Multi-stage build for production deployment
# =============================================================================

# ---------------------
# Builder Stage
# ---------------------
FROM python:3.13-slim AS builder

WORKDIR /app

# Install uv for dependency management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies (frozen = exact versions from lockfile)
RUN uv sync --frozen --no-dev --no-install-project

# ---------------------
# Production Stage
# ---------------------
FROM python:3.13-slim

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /app/.venv /app/.venv

# Copy application code
COPY app/ ./app/

# Add venv to PATH
ENV PATH="/app/.venv/bin:$PATH"

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

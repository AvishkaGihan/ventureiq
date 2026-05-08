"""VentureIQ API - FastAPI Application."""

from contextlib import asynccontextmanager

from fastapi import FastAPI

from app.api.v1.router import api_v1_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan context manager.

    Handles startup and shutdown events.
    Startup: DB connections, cache warmup, etc. (added in later stories)
    Shutdown: Graceful cleanup of resources.
    """
    # Startup logic — added in later stories (1.2, 1.3)
    yield
    # Shutdown logic — added in later stories


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(
        title="VentureIQ API",
        description="AI-powered startup idea validation platform",
        version="0.1.0",
        lifespan=lifespan,
    )

    app.include_router(api_v1_router, prefix="/api/v1")

    return app


app = create_app()

"""Health check endpoint."""

import uuid

from fastapi import APIRouter

router = APIRouter()


@router.get("/health")
async def health_check() -> dict:
    """Health check endpoint.

    Returns the service health status in the standard envelope format.
    """
    return {
        "data": {
            "status": "healthy",
            "version": "0.1.0",
        },
        "meta": {
            "request_id": str(uuid.uuid4()),
        },
    }

"""Unit tests for the health check endpoint."""

import uuid


def test_health_check_returns_200(client):
    """Test that the health endpoint returns a 200 status code."""
    response = client.get("/api/v1/health")
    assert response.status_code == 200


def test_health_check_returns_healthy_status(client):
    """Test that the health endpoint returns healthy status."""
    response = client.get("/api/v1/health")
    data = response.json()
    assert data["data"]["status"] == "healthy"


def test_health_check_returns_version(client):
    """Test that the health endpoint returns the correct version."""
    response = client.get("/api/v1/health")
    data = response.json()
    assert data["data"]["version"] == "0.1.0"


def test_health_check_envelope_format(client):
    """Test that the health endpoint uses the standard envelope format with data and meta keys."""
    response = client.get("/api/v1/health")
    data = response.json()

    # Must have top-level 'data' and 'meta' keys
    assert "data" in data, "Response missing 'data' key"
    assert "meta" in data, "Response missing 'meta' key"

    # Data should contain status and version
    assert "status" in data["data"]
    assert "version" in data["data"]

    # Meta should contain request_id
    assert "request_id" in data["meta"]


def test_health_check_request_id_is_valid_uuid(client):
    """Test that the request_id in meta is a valid UUID v4."""
    response = client.get("/api/v1/health")
    data = response.json()
    request_id = data["meta"]["request_id"]

    # Should not raise ValueError if valid UUID
    parsed = uuid.UUID(request_id)
    assert parsed.version == 4


def test_health_check_unique_request_ids(client):
    """Test that each request gets a unique request_id."""
    response1 = client.get("/api/v1/health")
    response2 = client.get("/api/v1/health")

    id1 = response1.json()["meta"]["request_id"]
    id2 = response2.json()["meta"]["request_id"]

    assert id1 != id2, "Each request should have a unique request_id"


def test_health_check_content_type(client):
    """Test that the health endpoint returns JSON content type."""
    response = client.get("/api/v1/health")
    assert "application/json" in response.headers["content-type"]

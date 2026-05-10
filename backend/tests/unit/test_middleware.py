"""Unit tests for Request ID middleware."""


def test_request_id_header_matches_meta(client):
    """Ensure X-Request-ID header matches meta.request_id."""
    response = client.get("/api/v1/health")

    assert "X-Request-ID" in response.headers
    request_id = response.headers["X-Request-ID"]

    assert response.json()["meta"]["request_id"] == request_id


def test_request_id_unique_per_request(client):
    """Ensure each request receives a unique request_id."""
    response_one = client.get("/api/v1/health")
    response_two = client.get("/api/v1/health")

    assert response_one.headers["X-Request-ID"] != response_two.headers["X-Request-ID"]

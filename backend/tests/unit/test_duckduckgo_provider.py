"""Unit tests for DuckDuckGo provider."""

import asyncio
from unittest.mock import AsyncMock, patch

import pytest

from app.core.exceptions import ProviderRateLimitedError
from app.providers.search.base import SearchResult
from app.providers.search.duckduckgo import DuckDuckGoProvider


def _run_sync(func, *args):
    return func(*args)


def test_duckduckgo_search_maps_results():
    """Ensure search returns SearchResult list."""
    provider = DuckDuckGoProvider()
    expected = [SearchResult(title="Title", url="https://example.com", snippet="Snippet")]

    with (
        patch("app.providers.search.duckduckgo.asyncio.to_thread", new=AsyncMock(side_effect=_run_sync)),
        patch.object(provider, "_sync_search", return_value=expected) as sync_mock,
    ):
        result = asyncio.run(provider.search("query", num_results=1))

    assert result == expected
    sync_mock.assert_called_once_with("query", 1)


def test_duckduckgo_retry_on_rate_limit():
    """Ensure provider retries on rate limit and succeeds."""
    provider = DuckDuckGoProvider()
    expected = [SearchResult(title="Title", url="https://example.com", snippet="Snippet")]
    side_effects = [ProviderRateLimitedError(), ProviderRateLimitedError(), expected]

    with (
        patch("app.providers.search.duckduckgo.asyncio.to_thread", new=AsyncMock(side_effect=_run_sync)),
        patch.object(provider, "_sync_search", side_effect=side_effects) as sync_mock,
        patch("app.providers.search.duckduckgo.asyncio.sleep", new=AsyncMock()),
    ):
        result = asyncio.run(provider.search("query"))

    assert result == expected
    assert sync_mock.call_count == 3


def test_duckduckgo_rate_limit_exhausted():
    """Ensure provider raises after exhausting retries."""
    provider = DuckDuckGoProvider()

    with (
        patch("app.providers.search.duckduckgo.asyncio.to_thread", new=AsyncMock(side_effect=_run_sync)),
        patch.object(provider, "_sync_search", side_effect=ProviderRateLimitedError()),
        patch("app.providers.search.duckduckgo.asyncio.sleep", new=AsyncMock()),
        pytest.raises(ProviderRateLimitedError),
    ):
        asyncio.run(provider.search("query"))

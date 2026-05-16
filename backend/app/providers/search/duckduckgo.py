"""DuckDuckGo search provider implementation."""

from __future__ import annotations

import asyncio

from ddgs import DDGS

from app.core.exceptions import ProviderRateLimitedError, ProviderUnavailableError
from app.core.logging import get_logger
from app.providers.search.base import SearchProvider, SearchResult


class DuckDuckGoProvider(SearchProvider):
    """Search provider backed by DuckDuckGo."""

    def __init__(self, retries: int = 2, backoff_seconds: float = 1.0) -> None:
        self._retries = retries
        self._backoff_seconds = backoff_seconds
        self._logger = get_logger(__name__)

    async def search(self, query: str, num_results: int = 5) -> list[SearchResult]:
        """Search DuckDuckGo with retry on rate limiting."""
        last_error: Exception | None = None
        for attempt in range(self._retries + 1):
            try:
                # Wrap blocking sync search in a thread and force list conversion
                # inside the thread to catch generator exceptions during iteration.
                return await asyncio.to_thread(self._sync_search, query, num_results)
            except ProviderRateLimitedError as exc:
                last_error = exc
                if attempt >= self._retries:
                    break
                backoff = self._backoff_seconds * (2**attempt)
                self._logger.warning(
                    "DuckDuckGo rate limited; retrying",
                    extra={"extra_data": {"attempt": attempt + 1, "backoff_seconds": backoff}},
                )
                await asyncio.sleep(backoff)
            except Exception as exc:  # noqa: BLE001 - surface provider failures via custom error
                raise ProviderUnavailableError(details={"error": str(exc)}) from exc
        raise ProviderRateLimitedError(details={"error": str(last_error)})

    def _sync_search(self, query: str, num_results: int) -> list[SearchResult]:
        """Run the DuckDuckGo query synchronously and return a list."""
        try:
            with DDGS() as ddgs:
                # Force iteration to list inside the sync context
                results = list(ddgs.text(query, max_results=num_results))
        except Exception as exc:  # noqa: BLE001 - map provider-specific errors
            if self._is_rate_limited(exc):
                raise ProviderRateLimitedError(details={"error": str(exc)}) from exc
            raise

        return [
            SearchResult(
                title=result.get("title", ""),
                url=result.get("href", ""),
                snippet=result.get("body", ""),
            )
            for result in results
        ]

    @staticmethod
    def _is_rate_limited(exc: Exception) -> bool:
        """Return True when the exception indicates rate limiting."""
        message = str(exc).lower()
        return "429" in message or "rate limit" in message or "too many requests" in message

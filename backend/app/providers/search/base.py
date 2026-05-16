"""Search provider abstraction layer."""

from __future__ import annotations

from abc import ABC, abstractmethod

from pydantic import BaseModel


class SearchResult(BaseModel):
    """Search result payload."""

    title: str
    url: str
    snippet: str


class SearchProvider(ABC):
    """Abstract base class for search providers."""

    @abstractmethod
    async def search(self, query: str, num_results: int = 5) -> list[SearchResult]:
        """Search for query and return a list of results."""
        raise NotImplementedError

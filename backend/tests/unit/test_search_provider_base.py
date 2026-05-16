"""Unit tests for search provider abstractions."""

import pytest

from app.providers.search.base import SearchProvider, SearchResult


def test_search_provider_is_abstract():
    """Ensure the SearchProvider cannot be instantiated."""
    with pytest.raises(TypeError):
        SearchProvider()


def test_search_result_fields():
    """Ensure SearchResult validates required fields."""
    result = SearchResult(title="Title", url="https://example.com", snippet="Snippet")
    assert result.title == "Title"
    assert result.url == "https://example.com"
    assert result.snippet == "Snippet"

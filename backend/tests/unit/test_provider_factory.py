"""Unit tests for provider factory functions."""

from unittest.mock import patch

import pytest

from app.core.config import Settings
from app.providers.factory import get_llm_provider, get_search_provider
from app.providers.llm.failover import LLMFailoverManager
from app.providers.search.duckduckgo import DuckDuckGoProvider


@patch("app.providers.factory.OpenRouterProvider")
@patch("app.providers.factory.GeminiProvider")
def test_get_llm_provider_builds_failover(mock_gemini, mock_openrouter):
    """Ensure LLM factory builds failover stack."""
    settings = Settings(
        GEMINI_API_KEY="g",
        OPENROUTER_API_KEY="o",
        OPENROUTER_MODEL="model",
        LLM_PRIMARY_PROVIDER="gemini",
        LLM_FALLBACK_PROVIDER="openrouter",
    )

    provider = get_llm_provider(settings)

    assert isinstance(provider, LLMFailoverManager)
    mock_gemini.assert_called_once_with(api_key="g")
    mock_openrouter.assert_called_once_with(api_key="o", model="model")


def test_get_search_provider_duckduckgo():
    """Ensure search factory builds DuckDuckGo provider."""
    settings = Settings(SEARCH_PRIMARY_PROVIDER="duckduckgo")

    provider = get_search_provider(settings)

    assert isinstance(provider, DuckDuckGoProvider)


def test_get_search_provider_unknown():
    """Ensure unknown search providers raise errors."""
    settings = Settings(SEARCH_PRIMARY_PROVIDER="unknown")

    with pytest.raises(ValueError):
        get_search_provider(settings)

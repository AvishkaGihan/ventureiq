"""Contract tests ensuring provider swap requires no code changes."""

import asyncio
from unittest.mock import AsyncMock, MagicMock, patch

from app.providers.llm.base import LLMProvider
from app.providers.llm.gemini import GeminiProvider
from app.providers.llm.openrouter import OpenRouterProvider
from app.providers.search.base import SearchProvider, SearchResult
from app.providers.search.duckduckgo import DuckDuckGoProvider


def _run_sync(func, *args):
    return func(*args)


async def _consume_llm(provider: LLMProvider) -> str:
    return await provider.generate("prompt")


async def _consume_search(provider: SearchProvider) -> list[SearchResult]:
    return await provider.search("query", num_results=1)


@patch("app.providers.llm.gemini.ChatGoogleGenerativeAI")
@patch("app.providers.llm.openrouter.ChatOpenRouter")
def test_llm_provider_swap(mock_openrouter, mock_gemini):
    """Ensure LLM consumers can swap providers without changes."""
    gemini_llm = MagicMock()
    gemini_llm.ainvoke = AsyncMock(return_value=MagicMock(content="gemini"))
    mock_gemini.return_value = gemini_llm

    openrouter_llm = MagicMock()
    openrouter_llm.ainvoke = AsyncMock(return_value=MagicMock(content="openrouter"))
    mock_openrouter.return_value = openrouter_llm

    gemini_provider = GeminiProvider(api_key="gemini-key")
    openrouter_provider = OpenRouterProvider(api_key="openrouter-key")

    gemini_result = asyncio.run(_consume_llm(gemini_provider))
    openrouter_result = asyncio.run(_consume_llm(openrouter_provider))

    assert gemini_result == "gemini"
    assert openrouter_result == "openrouter"


def test_search_provider_swap():
    """Ensure search consumers can swap providers without changes."""
    provider = DuckDuckGoProvider()
    expected = [SearchResult(title="Title", url="https://example.com", snippet="Snippet")]

    with (
        patch("app.providers.search.duckduckgo.asyncio.to_thread", new=AsyncMock(side_effect=_run_sync)),
        patch.object(provider, "_sync_search", return_value=expected),
    ):
        result = asyncio.run(_consume_search(provider))

    assert result == expected

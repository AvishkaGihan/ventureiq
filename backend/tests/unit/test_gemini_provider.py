"""Unit tests for the Gemini provider."""

import asyncio
from unittest.mock import AsyncMock, MagicMock, patch

from app.providers.llm.gemini import GeminiProvider


def _stream_chunks(contents: list[str]):
    async def _generator():
        for content in contents:
            yield MagicMock(content=content)

    return _generator()


@patch("app.providers.llm.gemini.ChatGoogleGenerativeAI")
def test_gemini_generate(mock_llm_class):
    """Ensure generate returns string content."""
    mock_llm = MagicMock()
    mock_llm.ainvoke = AsyncMock(return_value=MagicMock(content="hello"))
    mock_llm_class.return_value = mock_llm

    provider = GeminiProvider(api_key="test-key")

    result = asyncio.run(provider.generate("prompt"))

    assert result == "hello"
    mock_llm.ainvoke.assert_awaited_once_with("prompt")


@patch("app.providers.llm.gemini.ChatGoogleGenerativeAI")
def test_gemini_stream(mock_llm_class):
    """Ensure stream yields token strings."""
    mock_llm = MagicMock()
    mock_llm.astream.return_value = _stream_chunks(["a", "b"])
    mock_llm_class.return_value = mock_llm

    provider = GeminiProvider(api_key="test-key")

    async def _collect():
        return [chunk async for chunk in provider.stream("prompt")]

    result = asyncio.run(_collect())

    assert result == ["a", "b"]


@patch("app.providers.llm.gemini.ChatGoogleGenerativeAI")
def test_gemini_model_info(mock_llm_class):
    """Ensure model metadata is populated."""
    mock_llm_class.return_value = MagicMock()

    provider = GeminiProvider(api_key="test-key")
    info = provider.get_model_info()

    assert info.name == "gemini-2.5-flash"
    assert info.provider == "google"
    assert info.supports_streaming is True

"""Unit tests for LLM failover manager."""

import asyncio
from unittest.mock import AsyncMock, patch

import pytest

from app.core.exceptions import ProviderUnavailableError
from app.providers.llm.base import LLMConfig, LLMProvider, ModelInfo
from app.providers.llm.failover import LLMFailoverManager


class DummyProvider(LLMProvider):
    """Test double for LLM providers."""

    def __init__(
        self,
        name: str,
        provider: str,
        generate_failures: int = 0,
        stream_failures: int = 0,
        stream_chunks: list[str] | None = None,
    ) -> None:
        self._name = name
        self._provider = provider
        self._generate_failures = generate_failures
        self._stream_failures = stream_failures
        self._stream_chunks = stream_chunks or ["ok"]
        self.generate_calls = 0
        self.stream_calls = 0

    async def generate(self, prompt: str, config: LLMConfig | None = None) -> str:
        self.generate_calls += 1
        if self._generate_failures > 0:
            self._generate_failures -= 1
            raise RuntimeError("boom")
        return "generated"

    async def stream(self, prompt: str, config: LLMConfig | None = None):
        self.stream_calls += 1
        if self._stream_failures > 0:
            self._stream_failures -= 1
            raise RuntimeError("boom")
        for chunk in self._stream_chunks:
            yield chunk

    def get_model_info(self) -> ModelInfo:
        return ModelInfo(
            name=self._name,
            provider=self._provider,
            max_tokens=100,
            supports_streaming=True,
        )


def test_failover_primary_success():
    """Primary provider succeeds without failover."""
    primary = DummyProvider("primary", "p")
    fallback = DummyProvider("fallback", "f")
    manager = LLMFailoverManager(primary=primary, fallback=fallback)

    result = asyncio.run(manager.generate("prompt"))

    assert result == "generated"
    assert primary.generate_calls == 1
    assert fallback.generate_calls == 0


def test_failover_primary_failure_triggers_fallback():
    """Primary failure triggers fallback after retries."""
    primary = DummyProvider("primary", "p", generate_failures=3)
    fallback = DummyProvider("fallback", "f")
    manager = LLMFailoverManager(primary=primary, fallback=fallback)

    with patch("app.providers.llm.failover.asyncio.sleep", new=AsyncMock()) as sleep_mock:
        result = asyncio.run(manager.generate("prompt"))

    assert result == "generated"
    assert primary.generate_calls == 3
    assert fallback.generate_calls == 1
    sleep_mock.assert_awaited()


def test_failover_both_providers_fail():
    """Both providers failing raises ProviderUnavailableError."""
    primary = DummyProvider("primary", "p", generate_failures=3)
    fallback = DummyProvider("fallback", "f", generate_failures=3)
    manager = LLMFailoverManager(primary=primary, fallback=fallback)

    with (
        patch("app.providers.llm.failover.asyncio.sleep", new=AsyncMock()),
        pytest.raises(ProviderUnavailableError),
    ):
        asyncio.run(manager.generate("prompt"))


def test_stream_failover_primary_failure_triggers_fallback():
    """Streaming failover uses fallback when primary fails before yielding."""
    primary = DummyProvider("primary", "p", stream_failures=3)
    fallback = DummyProvider("fallback", "f", stream_chunks=["a", "b"])
    manager = LLMFailoverManager(primary=primary, fallback=fallback)

    async def _collect():
        return [chunk async for chunk in manager.stream("prompt")]

    with patch("app.providers.llm.failover.asyncio.sleep", new=AsyncMock()):
        result = asyncio.run(_collect())

    assert result == ["a", "b"]
    assert primary.stream_calls == 3
    assert fallback.stream_calls == 1

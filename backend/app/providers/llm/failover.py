"""Failover management for LLM providers."""

from __future__ import annotations

import asyncio
from collections.abc import AsyncIterator

from app.core.exceptions import ProviderUnavailableError
from app.core.logging import get_logger
from app.providers.llm.base import LLMConfig, LLMProvider, ModelInfo


class LLMFailoverManager(LLMProvider):
    """Transparent failover between primary and fallback LLM providers."""

    def __init__(
        self,
        primary: LLMProvider,
        fallback: LLMProvider,
        retries: int = 2,
        backoff_seconds: float = 2.0,
    ) -> None:
        self._primary = primary
        self._fallback = fallback
        self._retries = max(0, retries)
        self._backoff_seconds = backoff_seconds
        self._logger = get_logger(__name__)

    async def generate(self, prompt: str, config: LLMConfig | None = None) -> str:
        """Generate a full response with automatic failover."""
        try:
            return await self._generate_with_retries(self._primary, prompt, config)
        except ProviderUnavailableError as exc:
            self._log_failover("generate", exc)
            return await self._generate_with_retries(self._fallback, prompt, config)

    async def stream(self, prompt: str, config: LLMConfig | None = None) -> AsyncIterator[str]:
        """Stream response tokens with automatic failover."""
        yielded = False
        try:
            async for chunk in self._stream_with_retries(self._primary, prompt, config):
                yielded = True
                yield chunk
            return
        except ProviderUnavailableError as exc:
            if yielded:
                # Primary failed mid-stream; do NOT failover to restart from fallback
                # This prevents duplicate/corrupted output.
                self._logger.error(
                    "Primary LLM failed mid-stream; cannot failover",
                    extra={"extra_data": {"error": str(exc)}},
                )
                raise
            self._log_failover("stream", exc)

        async for chunk in self._stream_with_retries(self._fallback, prompt, config):
            yield chunk

    def get_model_info(self) -> ModelInfo:
        """Return primary provider model metadata."""
        return self._primary.get_model_info()

    async def _generate_with_retries(
        self, provider: LLMProvider, prompt: str, config: LLMConfig | None
    ) -> str:
        last_error: Exception | None = None
        for attempt in range(self._retries + 1):
            try:
                return await provider.generate(prompt, config)
            except Exception as exc:  # noqa: BLE001 - surface provider failures via custom error
                last_error = exc
                if attempt >= self._retries:
                    break
                await asyncio.sleep(self._backoff_seconds)
        raise ProviderUnavailableError(details={"error": str(last_error)})

    async def _stream_with_retries(
        self, provider: LLMProvider, prompt: str, config: LLMConfig | None
    ) -> AsyncIterator[str]:
        last_error: Exception | None = None
        for attempt in range(self._retries + 1):
            yielded = False
            try:
                async for chunk in provider.stream(prompt, config):
                    yielded = True
                    yield chunk
                return
            except Exception as exc:  # noqa: BLE001 - surface provider failures via custom error
                last_error = exc
                if yielded:
                    break
                if attempt >= self._retries:
                    break
                await asyncio.sleep(self._backoff_seconds)
        raise ProviderUnavailableError(details={"error": str(last_error)})

    def _log_failover(self, method: str, exc: Exception) -> None:
        """Log failover events for observability."""
        primary_info = self._safe_model_info(self._primary)
        fallback_info = self._safe_model_info(self._fallback)
        self._logger.warning(
            "LLM failover triggered",
            extra={
                "extra_data": {
                    "method": method,
                    "primary_provider": primary_info.provider,
                    "primary_model": primary_info.name,
                    "fallback_provider": fallback_info.provider,
                    "fallback_model": fallback_info.name,
                    "reason": str(exc),
                }
            },
        )

    @staticmethod
    def _safe_model_info(provider: LLMProvider) -> ModelInfo:
        """Return model info while guarding against unexpected errors."""
        try:
            return provider.get_model_info()
        except Exception:  # noqa: BLE001 - best-effort metadata for logging
            return ModelInfo(name="unknown", provider="unknown", max_tokens=0, supports_streaming=False)

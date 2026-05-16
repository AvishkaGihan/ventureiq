"""OpenRouter LLM provider implementation."""

from __future__ import annotations

from collections.abc import AsyncIterator

from langchain_openrouter import ChatOpenRouter

from app.providers.llm.base import LLMConfig, LLMProvider, ModelInfo


class OpenRouterProvider(LLMProvider):
    """LLM provider backed by OpenRouter."""

    _DEFAULT_MODEL = "google/gemini-2.5-flash"
    _MAX_TOKENS = 8192

    def __init__(self, api_key: str, model: str | None = None) -> None:
        self._model = model or self._DEFAULT_MODEL
        self._llm = ChatOpenRouter(
            model=self._model,
            openrouter_api_key=api_key,
        )

    async def generate(self, prompt: str, config: LLMConfig | None = None) -> str:
        """Generate a full response from OpenRouter."""
        cfg = config or LLMConfig()
        self._apply_config(cfg)
        response = await self._llm.ainvoke(prompt)
        return str(getattr(response, "content", ""))

    async def stream(self, prompt: str, config: LLMConfig | None = None) -> AsyncIterator[str]:
        """Stream response tokens from OpenRouter."""
        cfg = config or LLMConfig()
        self._apply_config(cfg)
        async for chunk in self._llm.astream(prompt):
            content = getattr(chunk, "content", "")
            if content:
                yield str(content)

    def get_model_info(self) -> ModelInfo:
        """Return OpenRouter model metadata."""
        return ModelInfo(
            name=self._model,
            provider="openrouter",
            max_tokens=self._MAX_TOKENS,
            supports_streaming=True,
        )

    def _apply_config(self, config: LLMConfig) -> None:
        """Apply request-level configuration to the underlying client."""
        if hasattr(self._llm, "temperature"):
            self._llm.temperature = config.temperature
        if hasattr(self._llm, "max_tokens"):
            self._llm.max_tokens = config.max_output_tokens
        if hasattr(self._llm, "max_output_tokens"):
            self._llm.max_output_tokens = config.max_output_tokens
        if hasattr(self._llm, "top_p"):
            self._llm.top_p = config.top_p
        if config.stop_sequences and hasattr(self._llm, "stop"):
            self._llm.stop = config.stop_sequences

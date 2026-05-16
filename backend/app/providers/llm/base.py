"""LLM provider abstraction layer."""

from __future__ import annotations

from abc import ABC, abstractmethod
from collections.abc import AsyncIterator

from pydantic import BaseModel


class ModelInfo(BaseModel):
    """LLM model metadata."""

    name: str
    provider: str
    max_tokens: int
    supports_streaming: bool


class LLMConfig(BaseModel):
    """Per-request LLM configuration."""

    temperature: float = 0.7
    max_output_tokens: int = 4096
    top_p: float = 0.95
    stop_sequences: list[str] | None = None


class LLMProvider(ABC):
    """Abstract base class for LLM providers."""

    @abstractmethod
    async def generate(self, prompt: str, config: LLMConfig | None = None) -> str:
        """Generate a complete response from the LLM."""
        raise NotImplementedError

    @abstractmethod
    async def stream(self, prompt: str, config: LLMConfig | None = None) -> AsyncIterator[str]:
        """Stream response tokens from the LLM."""
        raise NotImplementedError

    @abstractmethod
    def get_model_info(self) -> ModelInfo:
        """Return model metadata."""
        raise NotImplementedError

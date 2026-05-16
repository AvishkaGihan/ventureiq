"""Unit tests for LLM provider abstractions."""

import pytest

from app.providers.llm.base import LLMConfig, LLMProvider, ModelInfo


def test_llm_provider_is_abstract():
    """Ensure the LLMProvider cannot be instantiated."""
    with pytest.raises(TypeError):
        LLMProvider()


def test_model_info_fields():
    """Ensure ModelInfo validates required fields."""
    model = ModelInfo(name="model", provider="provider", max_tokens=1024, supports_streaming=True)
    assert model.name == "model"
    assert model.provider == "provider"
    assert model.max_tokens == 1024
    assert model.supports_streaming is True


def test_llm_config_defaults():
    """Ensure LLMConfig default values are applied."""
    config = LLMConfig()
    assert config.temperature == 0.7
    assert config.max_output_tokens == 4096
    assert config.top_p == 0.95
    assert config.stop_sequences is None

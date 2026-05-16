"""Provider factory utilities."""

from __future__ import annotations

from app.core.config import Settings, get_settings
from app.providers.llm.failover import LLMFailoverManager
from app.providers.llm.gemini import GeminiProvider
from app.providers.llm.openrouter import OpenRouterProvider
from app.providers.search.base import SearchProvider
from app.providers.search.duckduckgo import DuckDuckGoProvider


def get_llm_provider(settings: Settings | None = None) -> LLMFailoverManager:
    """Construct the LLM provider stack based on settings."""
    resolved = settings or get_settings()
    primary = _build_llm_provider(resolved.LLM_PRIMARY_PROVIDER, resolved)
    fallback = _build_llm_provider(resolved.LLM_FALLBACK_PROVIDER, resolved)
    return LLMFailoverManager(primary=primary, fallback=fallback)


def get_search_provider(settings: Settings | None = None) -> SearchProvider:
    """Construct the search provider based on settings."""
    resolved = settings or get_settings()
    provider_name = resolved.SEARCH_PRIMARY_PROVIDER.lower()
    if provider_name == "duckduckgo":
        return DuckDuckGoProvider()
    raise ValueError(f"Unknown search provider: {resolved.SEARCH_PRIMARY_PROVIDER}")


def _build_llm_provider(provider_name: str, settings: Settings) -> GeminiProvider | OpenRouterProvider:
    """Instantiate an LLM provider by name."""
    normalized = provider_name.lower()
    if normalized == "gemini":
        api_key = settings.GEMINI_API_KEY.get_secret_value()
        if not api_key:
            raise ValueError("GEMINI_API_KEY is not configured")
        return GeminiProvider(api_key=api_key)
    if normalized == "openrouter":
        api_key = settings.OPENROUTER_API_KEY.get_secret_value()
        if not api_key:
            raise ValueError("OPENROUTER_API_KEY is not configured")
        return OpenRouterProvider(
            api_key=api_key,
            model=settings.OPENROUTER_MODEL,
        )
    raise ValueError(f"Unknown LLM provider: {provider_name}")

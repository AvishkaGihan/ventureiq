"""Application configuration settings."""

from functools import lru_cache

from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Typed application settings loaded from environment variables."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False,
    )

    DATABASE_URL: str = Field(
        default="postgresql+asyncpg://ventureiq:ventureiq@localhost:5432/ventureiq",
        description="Async SQLAlchemy database URL.",
    )
    POSTGRES_USER: str = Field(default="ventureiq")
    POSTGRES_PASSWORD: SecretStr = Field(default="ventureiq")
    POSTGRES_DB: str = Field(default="ventureiq")

    REDIS_URL: str = Field(default="redis://localhost:6379")
    CHROMADB_URL: str = Field(default="http://localhost:8100")

    GEMINI_API_KEY: SecretStr = Field(default="")
    OPENROUTER_API_KEY: SecretStr = Field(default="")
    LLM_PRIMARY_PROVIDER: str = Field(default="gemini")
    LLM_FALLBACK_PROVIDER: str = Field(default="openrouter")
    SEARCH_PRIMARY_PROVIDER: str = Field(default="duckduckgo")
    OPENROUTER_MODEL: str = Field(default="google/gemini-2.5-flash")

    FIREBASE_PROJECT_ID: str = Field(default="")
    FIREBASE_SERVICE_ACCOUNT_PATH: str = Field(default="")

    JWT_SECRET_KEY: SecretStr = Field(default="")
    JWT_ALGORITHM: str = Field(default="HS256")
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = Field(default=60, gt=0)
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = Field(default=7, gt=0)

    RATE_LIMIT_FREE_TIER_MONTHLY: int = Field(default=3, ge=0)
    RATE_LIMIT_PRO_TIER_MONTHLY: int = Field(default=0, ge=0)
    RATE_LIMIT_ANONYMOUS_TIER_MONTHLY: int = Field(default=3, ge=0)
    RATE_LIMIT_ENABLED: bool = Field(default=True)
    RATE_LIMIT_ROUTE_PREFIXES: list[str] = Field(default_factory=lambda: ["/api/v1/ideas"])

    APP_ENV: str = Field(default="development")
    APP_DEBUG: bool = Field(default=True)
    LOG_LEVEL: str = Field(default="DEBUG")

    @property
    def is_development(self) -> bool:
        """Return True when running in development mode."""
        return self.APP_ENV.lower() == "development"


@lru_cache
def get_settings() -> Settings:
    """Return cached settings instance."""
    return Settings()

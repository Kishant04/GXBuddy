from __future__ import annotations

from typing import Optional

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Supabase
    SUPABASE_URL: str
    SUPABASE_KEY: str

    # AI — Gemini (preferred)
    GEMINI_API_KEY: Optional[str] = None
    GEMINI_MODEL: str = "gemini-2.0-flash"

    # AI — GLM / Ilmu (fallback)
    GLM_API_KEY: Optional[str] = None
    GLM_BASE_URL: str = "https://api.ilmu.ai/v1/chat/completions"
    GLM_MODEL: str = "ilmu-glm-5.1"

    # App
    DEBUG: bool = True
    DEMO_MODE: bool = True
    SECRET_KEY: str = "dev-secret-change-in-production"
    DEMO_RESET_ENABLED: bool = False
    DEMO_RESET_KEY: str = "local-demo-reset-key"

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()

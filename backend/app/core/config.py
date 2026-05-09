from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Supabase
    SUPABASE_URL: str
    SUPABASE_KEY: str

    # AI
    GLM_API_KEY: str
    GLM_BASE_URL: str
    GLM_MODEL: str

    # App
    DEBUG: bool = True
    SECRET_KEY: str

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()
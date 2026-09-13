import os
from typing import List, Optional
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # Server settings
    backend_host: str = "0.0.0.0"
    backend_port: int = 8000
    environment: str = "development"
    cors_origins: str = "*"

    # Government of India BHASHINI API Credentials
    bhashini_user_id: Optional[str] = None
    bhashini_api_key: Optional[str] = None
    bhashini_pipeline_id: Optional[str] = None
    bhashini_inference_url: str = (
        "https://dhruva-api.bhashini.gov.in/services/inference/pipeline"
    )
    bhashini_request_timeout: float = 15.0

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    @property
    def is_bhashini_configured(self) -> bool:
        """
        Returns True if authentic BHASHINI credentials are configured.
        Guards against placeholder strings.
        """
        if not self.bhashini_user_id or not self.bhashini_api_key:
            return False
        user_id = self.bhashini_user_id.strip().lower()
        api_key = self.bhashini_api_key.strip().lower()
        placeholders = {
            "your_bhashini_user_id_here",
            "your_bhashini_api_key_here",
            "your_user_id_here",
            "your_api_key_here",
            "none",
            "",
        }
        return user_id not in placeholders and api_key not in placeholders

    @property
    def parsed_cors_origins(self) -> List[str]:
        if self.cors_origins.strip() == "*":
            return ["*"]
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]


settings = Settings()

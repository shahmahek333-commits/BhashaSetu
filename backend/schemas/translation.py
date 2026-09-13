from typing import Optional
from pydantic import BaseModel, Field, field_validator


class TranslationRequest(BaseModel):
    source_language: str = Field(
        ...,
        description="Source language name or ISO code (e.g., 'Hindi', 'hi', 'Santhali', 'sat')",
    )
    target_language: str = Field(
        ...,
        description="Target language name or ISO code (e.g., 'Santhali', 'sat', 'Hindi', 'hi')",
    )
    text: str = Field(
        ...,
        min_length=1,
        max_length=5000,
        description="Text to be translated",
    )

    @field_validator("text")
    @classmethod
    def validate_text(cls, v: str) -> str:
        cleaned = v.strip()
        if not cleaned:
            raise ValueError("Text to translate cannot be empty or whitespace only.")
        return cleaned

    @field_validator("source_language", "target_language")
    @classmethod
    def validate_languages(cls, v: str) -> str:
        cleaned = v.strip()
        if not cleaned:
            raise ValueError("Language parameter cannot be empty.")
        return cleaned


class TranslationResponse(BaseModel):
    source_language: str
    target_language: str
    source_text: str
    translated_text: str
    status: str = "success"
    provider: str = "BHASHINI"
    phonetic_guide: Optional[str] = None
    details: Optional[str] = None

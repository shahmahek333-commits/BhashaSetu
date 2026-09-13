from typing import Optional
from pydantic import BaseModel, Field


class SpeechToTextRequest(BaseModel):
    audio_base64: str = Field(..., description="Base64 encoded audio bytes")
    language: str = Field(default="hi", description="Spoken language code (e.g., 'hi', 'sat')")
    audio_format: Optional[str] = Field(default="wav", description="Audio format (wav, mp3, etc.)")


class SpeechToTextResponse(BaseModel):
    recognized_text: str
    language: str
    status: str = "success"
    provider: str = "BHASHINI"
    details: Optional[str] = None

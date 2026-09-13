from typing import Optional
from pydantic import BaseModel, Field


class TextToSpeechRequest(BaseModel):
    text: str = Field(..., min_length=1, description="Text to synthesize to speech")
    target_language: str = Field(default="hi", description="Language code for audio output")
    gender: Optional[str] = Field(default="female", description="Voice gender (female/male)")


class TextToSpeechResponse(BaseModel):
    audio_base64: Optional[str] = None
    target_language: str
    status: str = "success"
    provider: str = "BHASHINI"
    details: Optional[str] = None

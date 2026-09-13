from typing import Optional
from pydantic import BaseModel, Field


class OcrRequest(BaseModel):
    image_base64: str = Field(..., description="Base64 encoded image bytes")
    source_language: Optional[str] = Field(default="hi", description="Expected script/language")


class OcrResponse(BaseModel):
    extracted_text: str
    detected_language: Optional[str] = "hi"
    status: str = "success"
    provider: str = "BHASHINI"
    details: Optional[str] = None

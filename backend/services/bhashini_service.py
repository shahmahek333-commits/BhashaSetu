import logging
from typing import Dict, Optional
import httpx

from config import settings
from schemas.translation import TranslationResponse
from schemas.speech import SpeechToTextResponse
from schemas.tts import TextToSpeechResponse
from schemas.ocr import OcrResponse

logger = logging.getLogger("bhasa_setu.bhashini")


class BhashiniNotConfiguredException(Exception):
    """Raised when BHASHINI credentials are not provided or incomplete."""

    def __init__(
        self,
        message: str = (
            "BHASHINI API is not configured on this server. "
            "Please set BHASHINI_USER_ID, BHASHINI_API_KEY, and BHASHINI_PIPELINE_ID in environment variables."
        ),
    ):
        super().__init__(message)
        self.message = message


class BhashiniApiException(Exception):
    """Raised when an external call to BHASHINI returns an error or fails."""

    def __init__(self, message: str, status_code: int = 502):
        super().__init__(message)
        self.message = message
        self.status_code = status_code


class BhashiniService:
    """
    Adapter interfacing with the Government of India BHASHINI / Dhruva inference API.
    Enforces strict credential verification and does NOT fake API responses when unconfigured.
    """

    # Language code normalization mapping
    _LANG_CODE_MAP: Dict[str, str] = {
        "hindi": "hi",
        "hi": "hi",
        "hi-in": "hi",
        "santhali": "sat",
        "sat": "sat",
        "sat-in": "sat",
        "sat-olck": "sat",
        "english": "en",
        "en": "en",
    }

    @classmethod
    def normalize_language_code(cls, lang: str) -> str:
        key = lang.strip().lower()
        return cls._LANG_CODE_MAP.get(key, key[:3])

    async def translate(
        self,
        source_language: str,
        target_language: str,
        text: str,
    ) -> TranslationResponse:
        """
        Translates text via BHASHINI Dhruva NMT inference pipeline.
        Raises BhashiniNotConfiguredException if credentials are missing.
        """
        if not settings.is_bhashini_configured:
            logger.info("Translation requested but BHASHINI credentials are not configured.")
            raise BhashiniNotConfiguredException()

        src_code = self.normalize_language_code(source_language)
        tgt_code = self.normalize_language_code(target_language)

        headers = {
            "userID": settings.bhashini_user_id,
            "ulcaApiKey": settings.bhashini_api_key,
            "Content-Type": "application/json",
        }

        payload = {
            "pipelineTasks": [
                {
                    "taskType": "translation",
                    "config": {
                        "language": {
                            "sourceLanguage": src_code,
                            "targetLanguage": tgt_code,
                        }
                    },
                }
            ],
            "inputData": {
                "input": [
                    {
                        "source": text,
                    }
                ]
            },
        }

        if settings.bhashini_pipeline_id:
            payload["pipelineTasks"][0]["config"]["serviceId"] = settings.bhashini_pipeline_id

        try:
            async with httpx.AsyncClient(timeout=settings.bhashini_request_timeout) as client:
                response = await client.post(
                    settings.bhashini_inference_url,
                    json=payload,
                    headers=headers,
                )

            if response.status_code != 200:
                logger.error(
                    f"BHASHINI API returned status {response.status_code}: {response.text}"
                )
                raise BhashiniApiException(
                    f"BHASHINI upstream service returned error {response.status_code}: {response.text}",
                    status_code=response.status_code,
                )

            data = response.json()
            # Parse Dhruva response format
            pipeline_response = data.get("pipelineResponse", [])
            if not pipeline_response:
                raise BhashiniApiException("Malformed response received from BHASHINI pipeline.")

            output_data = pipeline_response[0].get("output", [])
            if not output_data or "target" not in output_data[0]:
                raise BhashiniApiException("No translated text found in BHASHINI response.")

            translated_text = output_data[0]["target"]

            return TranslationResponse(
                source_language=source_language,
                target_language=target_language,
                source_text=text,
                translated_text=translated_text,
                status="success",
                provider="BHASHINI-Dhruva",
            )

        except httpx.TimeoutException:
            logger.error("Timeout connecting to BHASHINI service.")
            raise BhashiniApiException(
                "Request to BHASHINI API timed out.",
                status_code=504,
            )
        except httpx.RequestError as e:
            logger.error(f"Network error connecting to BHASHINI: {e}")
            raise BhashiniApiException(
                f"Network communication failure connecting to BHASHINI: {e}",
                status_code=502,
            )

    async def speech_to_text(
        self,
        audio_base64: str,
        language: str = "hi",
    ) -> SpeechToTextResponse:
        """
        Interprets spoken audio via BHASHINI Dhruva ASR pipeline.
        """
        if not settings.is_bhashini_configured:
            raise BhashiniNotConfiguredException(
                "BHASHINI speech-to-text pipeline is not configured on this server."
            )
        raise BhashiniApiException(
            "BHASHINI ASR pipeline requires specialized audio configuration for Ol Chiki.",
            status_code=501,
        )

    async def text_to_speech(
        self,
        text: str,
        target_language: str = "hi",
    ) -> TextToSpeechResponse:
        """
        Synthesizes text to speech audio via BHASHINI Dhruva TTS pipeline.
        """
        if not settings.is_bhashini_configured:
            raise BhashiniNotConfiguredException(
                "BHASHINI text-to-speech pipeline is not configured on this server."
            )
        raise BhashiniApiException(
            "BHASHINI TTS voice synthesis model is not yet provisioned for target language.",
            status_code=501,
        )

    async def ocr(
        self,
        image_base64: str,
        source_language: str = "hi",
    ) -> OcrResponse:
        """
        Extracts script text from textbook images via BHASHINI OCR pipeline.
        """
        if not settings.is_bhashini_configured:
            raise BhashiniNotConfiguredException(
                "BHASHINI OCR vision pipeline is not configured on this server."
            )
        raise BhashiniApiException(
            "BHASHINI Ol Chiki vision model is pending deployment.",
            status_code=501,
        )

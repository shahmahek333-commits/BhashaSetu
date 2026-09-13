from fastapi import APIRouter, HTTPException, status
from schemas.speech import SpeechToTextRequest, SpeechToTextResponse
from services.bhashini_service import (
    BhashiniService,
    BhashiniNotConfiguredException,
    BhashiniApiException,
)

router = APIRouter(prefix="/api", tags=["Speech"])
bhashini_service = BhashiniService()


@router.post(
    "/speech-to-text",
    response_model=SpeechToTextResponse,
    status_code=status.HTTP_200_OK,
    summary="Speech-to-text conversion via BHASHINI ASR",
)
async def speech_to_text(request: SpeechToTextRequest):
    """
    Converts audio input to recognized text via BHASHINI ASR pipeline.
    """
    try:
        result = await bhashini_service.speech_to_text(
            audio_base64=request.audio_base64,
            language=request.language,
        )
        return result
    except BhashiniNotConfiguredException as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail={
                "message": e.message,
                "error_code": "BHASHINI_NOT_CONFIGURED",
                "notice": "Santhali speech recognition is not supported by standard engines.",
            },
        )
    except BhashiniApiException as e:
        raise HTTPException(
            status_code=e.status_code,
            detail={
                "message": e.message,
                "error_code": "BHASHINI_SPEECH_UNAVAILABLE",
            },
        )

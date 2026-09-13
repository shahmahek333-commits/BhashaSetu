from fastapi import APIRouter, HTTPException, status
from schemas.tts import TextToSpeechRequest, TextToSpeechResponse
from services.bhashini_service import (
    BhashiniService,
    BhashiniNotConfiguredException,
    BhashiniApiException,
)

router = APIRouter(prefix="/api", tags=["TextToSpeech"])
bhashini_service = BhashiniService()


@router.post(
    "/text-to-speech",
    response_model=TextToSpeechResponse,
    status_code=status.HTTP_200_OK,
    summary="Text-to-speech synthesis via BHASHINI TTS",
)
async def text_to_speech(request: TextToSpeechRequest):
    """
    Synthesizes speech audio from vernacular text via BHASHINI TTS pipeline.
    """
    try:
        result = await bhashini_service.text_to_speech(
            text=request.text,
            target_language=request.target_language,
        )
        return result
    except BhashiniNotConfiguredException as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail={
                "message": e.message,
                "error_code": "BHASHINI_NOT_CONFIGURED",
                "notice": "Santhali audio synthesis requires BHASHINI model integration.",
            },
        )
    except BhashiniApiException as e:
        raise HTTPException(
            status_code=e.status_code,
            detail={
                "message": e.message,
                "error_code": "BHASHINI_TTS_UNAVAILABLE",
            },
        )

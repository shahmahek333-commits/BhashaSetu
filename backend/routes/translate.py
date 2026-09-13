from fastapi import APIRouter, HTTPException, status
from schemas.translation import TranslationRequest, TranslationResponse
from services.bhashini_service import (
    BhashiniService,
    BhashiniNotConfiguredException,
    BhashiniApiException,
)

router = APIRouter(prefix="/api", tags=["Translation"])
bhashini_service = BhashiniService()


@router.post(
    "/translate",
    response_model=TranslationResponse,
    status_code=status.HTTP_200_OK,
    summary="Translate text between Hindi and Santhali via BHASHINI",
)
async def translate_text(request: TranslationRequest):
    """
    Translates classroom vernacular text using the official BHASHINI pipeline.
    Returns HTTP 503 if credentials are not configured.
    """
    try:
        result = await bhashini_service.translate(
            source_language=request.source_language,
            target_language=request.target_language,
            text=request.text,
        )
        return result
    except BhashiniNotConfiguredException as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail={
                "message": e.message,
                "error_code": "BHASHINI_NOT_CONFIGURED",
                "suggested_action": "Switch to Demo Translation mode in the Flutter app.",
            },
        )
    except BhashiniApiException as e:
        raise HTTPException(
            status_code=e.status_code,
            detail={
                "message": e.message,
                "error_code": "BHASHINI_API_ERROR",
            },
        )

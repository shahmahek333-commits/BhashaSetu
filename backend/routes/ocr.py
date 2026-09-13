from fastapi import APIRouter, HTTPException, status
from schemas.ocr import OcrRequest, OcrResponse
from services.bhashini_service import (
    BhashiniService,
    BhashiniNotConfiguredException,
    BhashiniApiException,
)

router = APIRouter(prefix="/api", tags=["OCR"])
bhashini_service = BhashiniService()


@router.post(
    "/ocr",
    response_model=OcrResponse,
    status_code=status.HTTP_200_OK,
    summary="Textbook OCR extraction via BHASHINI Vision",
)
async def extract_text_from_image(request: OcrRequest):
    """
    Extracts printed script from textbook images via BHASHINI vision pipeline.
    """
    try:
        result = await bhashini_service.ocr(
            image_base64=request.image_base64,
            source_language=request.source_language or "hi",
        )
        return result
    except BhashiniNotConfiguredException as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail={
                "message": e.message,
                "error_code": "BHASHINI_NOT_CONFIGURED",
                "notice": "Ol Chiki vision OCR requires native BHASHINI model deployment.",
            },
        )
    except BhashiniApiException as e:
        raise HTTPException(
            status_code=e.status_code,
            detail={
                "message": e.message,
                "error_code": "BHASHINI_OCR_UNAVAILABLE",
            },
        )

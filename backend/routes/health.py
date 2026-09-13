from datetime import datetime, timezone
from fastapi import APIRouter
from config import settings

router = APIRouter(tags=["Health"])


@router.get("/health")
async def health_check():
    """
    Health check endpoint verifying that the FastAPI server is running.
    """
    return {
        "status": "healthy",
        "service": "bhasa-setu-backend",
        "version": "1.0.0",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "bhashini_configured": settings.is_bhashini_configured,
        "environment": settings.environment,
    }

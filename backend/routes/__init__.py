from .health import router as health_router
from .translate import router as translate_router
from .speech import router as speech_router
from .tts import router as tts_router
from .ocr import router as ocr_router

__all__ = [
    "health_router",
    "translate_router",
    "speech_router",
    "tts_router",
    "ocr_router",
]

import logging
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from config import settings
from routes import (
    health_router,
    translate_router,
    speech_router,
    tts_router,
    ocr_router,
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger("bhasa_setu.app")

app = FastAPI(
    title="BhasaSetu Translation Gateway API",
    description=(
        "Enterprise-grade translation gateway for BhasaSetu connecting primary classroom "
        "vernacular pedagogy with Government of India BHASHINI / Dhruva language infrastructure."
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.parsed_cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global unhandled exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled server exception on {request.url}: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "detail": {
                "message": "Internal gateway server error occurred.",
                "error_code": "INTERNAL_SERVER_ERROR",
            }
        },
    )


# Root info endpoint
@app.get("/", tags=["Info"])
async def root_info():
    return {
        "service": "BhasaSetu Translation Gateway",
        "status": "online",
        "documentation": "/docs",
        "health_check": "/health",
        "bhashini_configured": settings.is_bhashini_configured,
    }


# Include sub-routers
app.include_router(health_router)
app.include_router(translate_router)
app.include_router(speech_router)
app.include_router(tts_router)
app.include_router(ocr_router)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "main:app",
        host=settings.backend_host,
        port=settings.backend_port,
        reload=True,
    )

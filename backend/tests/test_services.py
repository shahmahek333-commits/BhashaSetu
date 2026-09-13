import sys
import os
from fastapi.testclient import TestClient

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from main import app

client = TestClient(app)


def test_speech_to_text_unconfigured_returns_503():
    response = client.post(
        "/api/speech-to-text",
        json={
            "audio_base64": "dGVzdF9hdWRpb19kYXRh",
            "language": "hi",
        },
    )
    assert response.status_code == 503
    data = response.json()
    assert data["detail"]["error_code"] == "BHASHINI_NOT_CONFIGURED"


def test_text_to_speech_unconfigured_returns_503():
    response = client.post(
        "/api/text-to-speech",
        json={
            "text": "नमस्ते",
            "target_language": "sat",
        },
    )
    assert response.status_code == 503
    data = response.json()
    assert data["detail"]["error_code"] == "BHASHINI_NOT_CONFIGURED"


def test_ocr_unconfigured_returns_503():
    response = client.post(
        "/api/ocr",
        json={
            "image_base64": "dGVzdF9pbWFnZV9kYXRh",
            "source_language": "hi",
        },
    )
    assert response.status_code == 503
    data = response.json()
    assert data["detail"]["error_code"] == "BHASHINI_NOT_CONFIGURED"

import sys
import os
from fastapi.testclient import TestClient

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from main import app

client = TestClient(app)


def test_translate_valid_request_unconfigured_bhashini_returns_503():
    """
    When BHASHINI credentials are not provided, translate MUST return 503
    with clear error structure rather than faking data.
    """
    response = client.post(
        "/api/translate",
        json={
            "source_language": "Hindi",
            "target_language": "Santhali",
            "text": "नमस्ते",
        },
    )
    assert response.status_code == 503
    data = response.json()
    assert "detail" in data
    assert data["detail"]["error_code"] == "BHASHINI_NOT_CONFIGURED"
    assert "Switch to Demo Translation" in data["detail"]["suggested_action"]


def test_translate_empty_text_returns_422():
    response = client.post(
        "/api/translate",
        json={
            "source_language": "Hindi",
            "target_language": "Santhali",
            "text": "   ",
        },
    )
    assert response.status_code == 422


def test_translate_missing_source_language_returns_422():
    response = client.post(
        "/api/translate",
        json={
            "target_language": "Santhali",
            "text": "नमस्ते",
        },
    )
    assert response.status_code == 422


def test_translate_missing_target_language_returns_422():
    response = client.post(
        "/api/translate",
        json={
            "source_language": "Hindi",
            "text": "नमस्ते",
        },
    )
    assert response.status_code == 422

import sys
import os
from fastapi.testclient import TestClient

# Ensure backend folder is in python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from main import app

client = TestClient(app)


def test_health_endpoint_returns_200():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "bhasa-setu-backend"
    assert "timestamp" in data
    assert "bhashini_configured" in data


def test_root_endpoint_returns_service_info():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "online"
    assert "documentation" in data

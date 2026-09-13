# BhasaSetu (भाषा सेतु / ᱵᱷᱟᱥᱟ ᱥᱮᱛᱩ)

> **Bilingual Primary Classroom Translation & Vernacular Pedagogy Platform**  
> *Connecting Hindi & Santhali (Ol Chiki Script) for Teachers and Students*  
> Developed for Smart India Hackathon (SIH 2026).

---

## 1. Project Overview

**BhasaSetu** is an offline-first, vernacular educational platform designed to bridge linguistic communication barriers in tribal and bilingual primary school classrooms. In regions where Santhali-speaking children enter primary school while textbooks and official curricula are primarily taught in Hindi, BhasaSetu enables teachers and young learners to communicate, teach, and learn seamlessly.

The platform provides dual teacher and student pedagogical experiences, bidirectional text translation, voice translation with speech capture, textbook OCR scanning, interactive flashcards, bilingual quizzes, a comprehensive classroom phrasebook, and a curated regional language bank.

---

## 2. Main Features

- **Dual Pedagogical Dashboards**:
  - **Teacher Mode**: Focused on Hindi-to-Santhali classroom instructions, curriculum translation, phrase delivery, student monitoring, and teaching tools.
  - **Student Mode**: Focused on Santhali-to-Hindi learning, vocabulary acquisition, flashcard drills, gamified quizzes, and pronunciation practice.
- **Bidirectional Text Translation**:
  - Hindi $\leftrightarrow$ Santhali translation supporting Devanagari script, Ol Chiki script, and phonetic Romanized pronunciation.
- **Voice Translation**:
  - Spoken audio capture with pulsing microphone indicator.
  - Authentic speech recognition for Hindi (`hi-IN`).
  - Text-to-speech audio synthesis for translated output.
- **Textbook OCR Scanner**:
  - Image capture via device Camera, photo Gallery, or pre-bundled primary textbook excerpts (Class 1 & 2 passages).
  - Devanagari script text recognition with immediate bilingual translation and audio pronunciation.
- **Classroom Phrases**:
  - Curated teacher phrasebook organized into 6 pedagogical categories: *Greetings*, *Instructions*, *Questions*, *Encouragement*, *Homework*, and *Examination*.
  - Pronunciation guides, audio synthesis, and one-tap clipboard copy.
- **Language Bank**:
  - Searchable bilingual repository covering everyday school, nature, family, and classroom vocabulary.
  - Category filters, script transliteration, and phonetic guides.
- **Flashcards & Gamified Quizzes**:
  - Interactive flip cards with spaced repetition tracking (*"I Know"*, *"Practice Again"*).
  - Multiple choice, picture identification, and true/false quizzes with instant score tracking and persistent performance history.
- **Offline-First Local Storage**:
  - SQLite database (`sqflite` / `sqflite_common_ffi`) caching user profiles, translation history, quiz attempts, and learning progress offline.
- **Enterprise FastAPI Translation Gateway**:
  - Modular Python backend with strict input validation, CORS middleware, and official Government of India BHASHINI / Dhruva inference pipeline adapter.

---

## 3. Technology Stack

### Frontend / Mobile & Web:
- **Framework**: Flutter 3.x / Dart 3.x
- **State & Local Storage**: `sqflite`, `sqflite_common_ffi`, `shared_preferences`, `path`
- **Audio & Media**: `speech_to_text`, `flutter_tts`, `image_picker`
- **HTTP Client**: `http` (cross-platform web and native engine)
- **UI & Icons**: Flutter Material Design 3, `cupertino_icons`

### Backend / Translation Gateway:
- **Framework**: Python 3.11+ / FastAPI
- **Server**: Uvicorn (ASGI)
- **Validation**: Pydantic v2 & `pydantic-settings`
- **HTTP Engine**: `httpx` (async client)
- **Integration Target**: Government of India BHASHINI / Dhruva NMT inference pipeline

---

## 4. Project Structure

```
bhasa_setu/
├── lib/
│   ├── core/                  # Theme, routes, constants, profile controller
│   │   ├── constants/
│   │   ├── routes/
│   │   ├── state/
│   │   └── theme/
│   ├── data/                  # SQLite database, seed data, models, repositories
│   │   ├── database/
│   │   ├── models/
│   │   └── repositories/
│   ├── models/                # Domain models (user profile, translation result)
│   ├── screens/               # UI screens organized by feature
│   │   ├── dashboard/         # Teacher & Student dashboards
│   │   ├── flashcards/        # Flashcard learning screen
│   │   ├── home/              # Main shell and tab navigation
│   │   ├── how_to_use/        # Classroom onboarding & guide
│   │   ├── language_bank/     # Searchable vocabulary bank
│   │   ├── learn/             # Student learning hub
│   │   ├── ocr/               # Textbook camera & sample OCR scanner
│   │   ├── phrases/           # Teacher classroom phrases
│   │   ├── profile/           # User profile & role setup
│   │   ├── progress/          # Student quiz & card progress tracking
│   │   ├── quiz/              # Quiz play & category selection
│   │   ├── translate/         # Text translation screen
│   │   └── voice/             # Voice translation screen
│   ├── services/              # API, Mock, Voice, TTS, and OCR services
│   └── widgets/               # Reusable UI widgets
├── test/                      # Comprehensive Flutter test suite (59 tests)
│   ├── widget_test.dart       # Stages 1–7 regression tests
│   ├── stage8_test.dart       # Classroom phrases & language bank tests
│   ├── stage9_test.dart       # Voice translation & OCR tests
│   └── stage10_test.dart      # FastAPI backend & BHASHINI client tests
├── backend/                   # Python FastAPI Translation Gateway
│   ├── main.py                # App entrypoint, CORS, routers
│   ├── config.py              # Pydantic BaseSettings (.env loading)
│   ├── requirements.txt       # Python dependencies
│   ├── .env.example           # Environment template
│   ├── routes/                # API endpoints (/health, /api/translate, etc.)
│   ├── schemas/               # Request/response models
│   ├── services/              # BHASHINI Dhruva pipeline adapter
│   └── tests/                 # Backend pytest test suite (9 tests)
├── android/                   # Android native configuration & permissions
├── web/                       # Web entrypoint & manifest
└── pubspec.yaml               # Flutter package configuration
```

---

## 5. Flutter Setup

### Prerequisites:
1. **Flutter SDK**: Version 3.19+ (Dart 3.3+) installed and on your system `PATH`.
2. **Web Support**: Google Chrome browser installed.

### Verification:
```bash
flutter doctor
```

---

## 6. Python Backend Setup

### Prerequisites:
1. **Python 3.11+**: Installed and available via `python` or `py` launcher.
2. **Pip**: Package installer for Python.

---

## 7. Dependency Installation

### Install Flutter Dependencies:
From the project root:
```bash
flutter pub get
```

### Install Backend Dependencies:
From the project root:
```bash
py -m pip install -r backend/requirements.txt
```

---

## 8. How to Run the Flutter Web Version

To run BhasaSetu in your browser via the local web server:

```bash
flutter run -d web-server --web-port 8080
```

Once started, open Chrome and navigate to:
```
http://localhost:8080
```

---

## 9. How to Run the FastAPI Backend

To start the translation gateway server locally:

```bash
py -m uvicorn main:app --app-dir backend --port 8000 --reload
```

Interactive API documentation will be available at:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`
- Health Check: `http://localhost:8000/health`

---

## 10. Environment Variable Setup

1. Copy the sample environment file in `backend/`:
   ```bash
   cp backend/.env.example backend/.env
   ```
2. Edit `backend/.env` with your preferred configuration:
   ```ini
   BACKEND_HOST=0.0.0.0
   BACKEND_PORT=8000
   ENVIRONMENT=development
   CORS_ORIGINS=*
   ```

---

## 11. BHASHINI Configuration

To connect live Government of India BHASHINI language models:

1. Obtain official API credentials from the [BHASHINI / ULCA Developer Portal](https://bhashini.gov.in).
2. Configure credentials in `backend/.env`:
   ```ini
   BHASHINI_USER_ID=your_actual_user_id
   BHASHINI_API_KEY=your_actual_api_key
   BHASHINI_PIPELINE_ID=your_assigned_pipeline_id
   BHASHINI_INFERENCE_URL=https://dhruva-api.bhashini.gov.in/services/inference/pipeline
   BHASHINI_REQUEST_TIMEOUT=15.0
   ```
3. When authentic credentials are provided, `POST /api/translate` proxies requests directly to the Dhruva NMT inference pipeline.

---

## 12. Demo Mode Explanation

**BhasaSetu is built to be 100% functional out-of-the-box in Demo Mode without requiring BHASHINI credentials or an active internet connection.**

- When BHASHINI credentials are not present in `.env`, the backend cleanly returns HTTP 503 (`BHASHINI_NOT_CONFIGURED`).
- The Flutter application seamlessly uses `MockTranslationService`, providing authentic translations for classroom phrases, daily vocabulary, greetings, instructions, and textbook passages.
- All local features (SQLite storage, profiles, flashcards, quizzes, phrasebook, language bank, audio playback) work offline without crashing.
- **Integrity Guarantee**: BhasaSetu never invents fake responses or displays simulated output as real BHASHINI output.

---

## 13. Testing Commands

### Run Backend Tests (Python):
```bash
py -m pytest backend/tests/ -v
```
*(All 9 tests will pass).*

### Run Static Analysis (Flutter/Dart):
```bash
flutter analyze
```
*(0 issues, 0 errors, 0 warnings).*

### Run Automated Flutter Test Suite:
```bash
flutter test
```
*(All 59 unit, widget, and integration tests across Stages 1–10 will pass).*

### Run Specific Stage Tests:
```bash
flutter test test/stage8_test.dart   # Classroom Phrases & Language Bank
flutter test test/stage9_test.dart   # Voice Translation & OCR
flutter test test/stage10_test.dart  # Backend API & Adapter Tests
```

---

## 14. Android Build Instructions

To build a debug Android APK:

```bash
flutter build apk --debug
```

The compiled APK will be generated at:
```
build/app/outputs/flutter-apk/app-debug.apk
```

---

## 15. Known Limitations

1. **BHASHINI Live Credentials**: Real translation, Ol Chiki speech recognition, and Ol Chiki OCR require active production API credentials from the Government of India BHASHINI platform. In their absence, the system operates in verified Demo Mode.
2. **Santhali Speech Recognition (ASR)**: Standard mobile/browser engines (Google Speech) do not yet support vernacular Santhali speech recognition. The app provides quick pedagogical prompt chips and manual editing for voice translation.
3. **Ol Chiki OCR**: Native Ol Chiki script optical recognition requires the specialized BHASHINI vision pipeline. Hindi Devanagari OCR is fully functional using textbook samples and camera input.

---

## 16. Current Android-Device Testing Limitation

- **No Physical Android Device**: Development and testing throughout all stages were conducted without a physical Android phone connected.
- **Web-Server Verification**: Full end-to-end interactive user flows were tested in Google Chrome via `flutter run -d web-server`.
- **Environment Gradle Constraint**: On this specific Windows build machine, running `flutter build apk --debug` triggers a `PKIX path building failed` Java SSL exception when the Gradle wrapper attempts to download Gradle distributions from `services.gradle.org` due to an unconfigured intermediate CA certificate in the local Java truststore. The Android Manifest, permissions, and Gradle configurations are verified intact.

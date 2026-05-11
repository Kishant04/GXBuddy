# GXBuddy — Project Instructions

GXBuddy is a smart financial companion that integrates with GXBank, providing AI-powered spending coaching, budget tracking, automated salary splitting (Autopilot), and social financial features (Squads).

## Repository Structure

- **`frontend/`**: Flutter mobile application.
- **`backend/`**: FastAPI application.
- **`docs/`**: Documentation and assets.
- **`legacy-mockups/`**: Reference mockup files.

## Architecture

- **Frontend:** Flutter (Dart) in `frontend/`
  - **State Management:** Riverpod (`flutter_riverpod`)
  - **Navigation:** GoRouter (`go_router`)
  - **Theming:** Custom GX-style theme in `lib/core/theme/`
- **Backend:** FastAPI (Python) in `backend/`
  - **Database:** Supabase
  - **Real-time:** WebSockets

## Getting Started

### Running the Frontend

```bash
cd GXBuddy/frontend
flutter pub get
flutter run
```

To connect to a local backend on an Android emulator:
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8001 --dart-define=WS_URL=ws://10.0.2.2:8001/ws --dart-define=USE_MOCK_DATA=false
```

### Running the Backend

```bash
cd GXBuddy/backend
# Create and activate a virtual environment
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## Development Conventions

- **Frontend paths:** All source code is in `frontend/lib/`.
- **Routing:** Declared in `frontend/lib/core/router/app_router.dart`.
- **State Management:** Use `AsyncNotifierProvider` for feature logic.
- **Data Models:** Use `*_model.dart` for API-compatible models.
- **Mock Data:** Stored in `frontend/lib/shared/constants/demo_data.dart`.
- **Security:** Never commit secrets. `*.env` is ignored.

## Common Tasks

- **Adding a new screen:** Create folder in `frontend/lib/features/`, register in `app_router.dart`.
- **Updating the Mascot:** mascot state driven by `DashboardResponse` or WebSocket events.
- **Changing API Endpoints:** Update `frontend/lib/core/api/endpoints.dart`.

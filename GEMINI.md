# GXBuddy — Project Instructions

GXBuddy is a smart financial companion that integrates with GXBank, providing AI-powered spending coaching, budget tracking, automated salary splitting (Autopilot), and social financial features (Squads).

## Architecture

- **Frontend:** Flutter (Dart)
  - **State Management:** Riverpod (`flutter_riverpod`)
  - **Navigation:** GoRouter (`go_router`)
  - **Theming:** Custom GX-style theme and typography in `lib/core/theme/`
  - **Patterns:** Feature-first directory structure (`lib/features/`)
- **Backend:** FastAPI (Python)
  - **Database:** Supabase
  - **Real-time:** WebSockets
  - **Background Jobs:** APScheduler
  - **AI:** GLM for classification and risk scoring

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Python 3.10+
- Android Studio / Xcode (for emulators)

### Running the Frontend

Navigate to the `GXBuddy` directory:

```bash
cd GXBuddy
flutter pub get
flutter run
```

To connect to a local backend on an Android emulator:
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000 --dart-define=WS_URL=ws://10.0.2.2:8000/ws --dart-define=USE_MOCK_DATA=false
```

### Running the Backend

Navigate to the `GXBuddy/backend` directory:

```bash
cd GXBuddy/backend
# Create and activate a virtual environment
python -m venv venv
.\venv\Scripts\activate  # Windows
source venv/bin/activate  # Unix/macOS
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Ensure a `.env` file exists in `GXBuddy/backend/` with the necessary credentials.

## Development Conventions

- **Surgical Edits:** Prioritize targeted updates to existing files.
- **Routing:** All routes must be declared in `lib/core/router/app_router.dart`. Use `context.push()` or `context.go()` for navigation.
- **State Management:** Use `StateNotifierProvider` or `AsyncNotifierProvider` for feature logic. Avoid direct mutation of state outside of controllers.
- **Data Models:** Use `*_model.dart` suffix for models that map to backend schemas.
- **Mock Data:** Initial demo data is stored in `lib/shared/constants/demo_data.dart`.
- **Security:**
  - Never log or commit secrets/API keys.
  - Sensitive files like `.env` are ignored by git.
  - Use `AuthTokenStore` for managing user sessions and tokens.

## Common Tasks

- **Adding a new screen:** Create a new folder in `lib/features/`, add the screen widget, and register the route in `app_router.dart`.
- **Updating the Mascot:** The mascot state is driven by the backend via `DashboardResponse` or WebSocket events (`RealtimeEvent`).
- **Changing API Endpoints:** Update `lib/core/api/endpoints.dart`.
- **Modifying Theme:** Edit `lib/core/theme/gx_colors.dart` or `lib/core/theme/app_theme.dart`.

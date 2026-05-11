# GXBuddy Frontend (Flutter)

## Getting Started

1.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

2.  **Run on Web (Chrome):**
    ```bash
    flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8001 --dart-define=WS_URL=ws://localhost:8001/ws --dart-define=USE_MOCK_DATA=false
    ```

3.  **Run on Android Emulator:**
    ```bash
    flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8001 --dart-define=WS_URL=ws://10.0.2.2:8001/ws --dart-define=USE_MOCK_DATA=false
    ```

## Development

- **Architecture:** Feature-first structure in `lib/features/`.
- **State Management:** Riverpod.
- **Routing:** GoRouter (declared in `lib/core/router/app_router.dart`).
- **API:** Repository pattern using `ApiClient` and `GxRepository`.

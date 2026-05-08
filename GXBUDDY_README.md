# GXBuddy Flutter Frontend

**Your Smart Financial Companion That Thinks Before You Spend**

---

## How to run

```bash
cd gxbuddy
flutter pub get
flutter run
```

Target Chrome (web) for the fastest demo:
```bash
flutter run -d chrome
```

Target Android/iOS as usual — no extra setup needed beyond Flutter SDK.

---

## Architecture overview

```
lib/
├── main.dart               # Entry point — ProviderScope + GXBuddyApp
├── app.dart                # MaterialApp wired to GXBankEntryScreen
├── core/                   # Infrastructure (theme, routing, API, WebSocket, utils)
├── models/                 # Pure Dart data models (JSON-serialisable)
├── repositories/           # Data layer (abstract contract + mock + API stub)
├── shared/                 # Reusable widgets + constants
└── features/               # One folder per screen/flow
    ├── gxbank/             # GXBank-style entry screen
    ├── home/               # Home screen + controllers + modals
    ├── spend/              # Spend screen
    ├── pockets/            # GX Pockets screen + autopilot config sheet
    ├── squad/              # Squad screen + streak shield modal + invite sheet
    ├── notifications/      # Notification preview screen
    └── profile/            # Profile screen
```

---

## Where mock data lives

`lib/shared/constants/demo_data.dart` — all initial state (budget, pockets, transactions,
squad, bills, alerts, autopilot config). Edit this file to change what the demo shows.

---

## How to switch from Mock → API repository

1. Open `lib/features/home/home_controller.dart`.
2. The provider at the bottom (`appStateProvider`) currently uses `AppStateNotifier`
   which operates on local state with `DemoData`.
3. To switch to real API, replace the `MockGxRepository` usage with `ApiGxRepository`:

```dart
// In any provider file:
final gxRepoProvider = Provider<GxRepository>((_) => ApiGxRepository(
  apiClient: ApiClient(),
  wsService: WebSocketService(),
));
```

4. Then update each controller to call `ref.watch(gxRepoProvider)` instead of
   mutating local state directly.

`MockGxRepository` → `lib/repositories/mock_gx_repository.dart`
`ApiGxRepository`  → `lib/repositories/api_gx_repository.dart` (stubs ready)

---

## Where API endpoints are defined

`lib/core/api/endpoints.dart` — all paths as `static const String` values.
`lib/core/config/app_config.dart` — base URL per environment.
`lib/core/config/environment.dart` — switch between `mock`, `staging`, `production`.

---

## Where WebSocket events are handled

`lib/core/realtime/realtime_event.dart` — typed event model.
`lib/core/realtime/websocket_service.dart` — connects to `{wsBaseUrl}/ws`.

In mock mode the `WebSocketService` returns an empty broadcast stream.
Events are driven by UI actions (demo buttons) via `AppStateNotifier`.

When the backend is ready:
1. Set `Environment.current = AppEnvironment.staging` in `environment.dart`.
2. Call `wsService.connect()` from a top-level provider and listen to events.
3. Map `RealtimeEventType` cases to `AppStateNotifier` mutations.

---

## Demo flow (for judges)

1. App launches to GXBank entry screen — tap **Open GXBuddy** on the mascot card.
2. Home screen shows mascot in **alert** state — food budget at 99%.
3. Tap **Spend RM100 Shopping** → 10-second Pause modal with risk score animation.
   - **Round Up RM2** → mascot celebrates, Emergency Fund +RM2.
   - **Cancel** → mascot calms down.
   - **Continue Anyway** → mascot panics, budget pushed over limit.
4. Tap **Receive Salary** → cinematic autopilot animation splits RM420 into 3 pockets.
   - 60-second countdown undo toast appears — tap **Undo** to reverse.
5. Open **Squad** tab → tap **Send Hold Strong** → Streak Shield modal for Kumar.
6. Open **Pockets** → tap **Configure Autopilot** → full config sheet.
7. **Profile** → toggle notifications and privacy settings live.

---

## Team integration notes

- **Backend team**: implement the FastAPI endpoints from `endpoints.dart`.
  The expected response shape for `/api/dashboard` is documented in
  `lib/models/dashboard_response.dart`.
- **AI team**: the mascot state (`calm/alert/panicked/celebrating`) is driven by
  the `MascotModel` inside `DashboardResponse`. Push real-time state via WebSocket
  using the `mascot_state` event type defined in `realtime_event.dart`.
- **No secrets, no API keys, no backend calls** are present in this frontend build.

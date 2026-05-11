# GXBuddy — Smart Financial Companion

GXBuddy is a smart financial companion that integrates with GXBank, providing AI-powered spending coaching, budget tracking, automated salary splitting (Autopilot), and social financial features (Squads).

This repository contains the backend and frontend services for GXBuddy.

## Repository Structure

- **`backend/`**: FastAPI application with Supabase integration.
- **`frontend/`**: Flutter mobile application.
- **`docs/`**: Documentation, screenshots, and uploads.
- **`legacy-mockups/`**: Original React/Claude Design mockup files (for reference only).

---

## Run the backend

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The backend requires a `backend/.env` file with Supabase and GLM credentials.
**Do not commit `backend/.env`** — it is listed in `.gitignore`.

---

## Run Flutter

### Android emulator (backend on host machine)

```bash
flutter run 
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 
  --dart-define=WS_URL=ws://10.0.2.2:8000/ws 
  --dart-define=USE_MOCK_DATA=false 
  --dart-define=DEV_USER_ID=your-supabase-uuid 
  --dart-define=DEV_TOKEN=your-supabase-jwt
```

`DEV_USER_ID` and `DEV_TOKEN` are seeded into the app automatically at startup —
no need to open Developer Settings and enter them manually.
They are passed at run-time only and are **never stored in source code**.

`10.0.2.2` is the Android emulator's alias for the host machine's `localhost`.
For a real device, replace with your machine's LAN IP (e.g. `192.168.1.10`).

### iOS Simulator (backend on same machine)

```bash
flutter run 
  --dart-define=API_BASE_URL=http://localhost:8000 
  --dart-define=WS_URL=ws://localhost:8000/ws 
  --dart-define=USE_MOCK_DATA=false 
  --dart-define=DEV_USER_ID=your-supabase-uuid 
  --dart-define=DEV_TOKEN=your-supabase-jwt
```

### Mock mode (no backend required)

```bash
flutter run --dart-define=USE_MOCK_DATA=true
```

All data comes from `lib/shared/constants/demo_data.dart`. No network calls are made.

---

## How to get your Supabase credentials

1. Sign in via the Supabase dashboard or call `supabase.auth.signInWithPassword` from any client.
2. Copy the `access_token` from the session response — this is your `DEV_TOKEN`.
3. Copy the `user.id` (UUID) from the session response — this is your `DEV_USER_ID`.
4. Pass both on the `flutter run` command line (see examples above).

The app seeds these into `AuthTokenStore` automatically on startup. No manual steps needed.

---

## How to connect to the backend at runtime (without rebuilding)

If you need to change credentials after the app is already running:

1. Open **Profile → Developer Settings**.
2. Set:
   - **API Base URL** — e.g. `http://10.0.2.2:8000`
   - **WebSocket URL** — e.g. `ws://10.0.2.2:8000/ws`
   - **User ID** — your Supabase user UUID
   - **Bearer Token** — your Supabase JWT (from `supabase.auth.currentSession.accessToken`)
3. Tap **Test Backend Connection** to verify the API is reachable.
4. Tap **Test Auth /me** to confirm the token is valid.
5. Tap **Save Settings** — all providers reload immediately.

Runtime overrides are stored in `SharedPreferences` and survive app restarts.
They take precedence over the compile-time `--dart-define` values.

---

## Where to find things

| What | Where |
|------|-------|
| API endpoint paths | `lib/core/api/endpoints.dart` |
| Compile-time config | `lib/core/config/app_config.dart` |
| Backend-compatible models | `lib/models/*_model.dart` |
| Repository interface | `lib/repositories/gx_repository.dart` |
| Mock implementation | `lib/repositories/mock_gx_repository.dart` |
| API implementation | `lib/repositories/api_gx_repository.dart` |
| Mock/API switch | `lib/providers/repository_provider.dart` |
| User ID resolution | `lib/providers/user_id_provider.dart` |
| WebSocket events | `lib/core/realtime/realtime_event.dart` |
| WebSocket handler | `lib/features/shell/app_shell.dart` |
| Demo data | `lib/shared/constants/demo_data.dart` |

---

## How to switch mock ↔ API mode

**At build time** (baked into the binary):
```bash
flutter run --dart-define=USE_MOCK_DATA=false   # real API
flutter run --dart-define=USE_MOCK_DATA=true    # mock
```

**At runtime** (no rebuild needed):
Profile → Developer Settings → Mock Mode toggle → Save Settings.

---

## How to get a Supabase JWT

1. Sign in via the Supabase dashboard or call `supabase.auth.signInWithPassword`.
2. Copy `session.accessToken` — this is your Bearer token.
3. Paste it into Developer Settings → Bearer Token field.
4. Paste your user UUID into the User ID field.

---

## Backend route summary

| Method | Path | Auth | Notes |
|--------|------|------|-------|
| GET | `/api/auth/health` | None | Health check |
| GET | `/api/auth/me` | Bearer | Returns `{user: {id, email}}` |
| GET | `/api/dashboard?user_id=` | None* | Full dashboard payload |
| POST | `/api/transactions` | Bearer | Creates tx, returns classification + mascot |
| GET | `/api/transactions?user_id=&limit=` | None* | Transaction list |
| GET | `/budgets?user_id=` | None* | Budget progress list |
| GET | `/bills?user_id=&days_ahead=` | None* | Upcoming bills |
| POST | `/api/pockets/` | Bearer | Create pocket |
| PATCH | `/api/pockets/{id}` | Bearer | Update pocket |
| DELETE | `/api/pockets/{id}` | Bearer | Delete pocket |
| POST | `/api/autopilot/trigger` | Bearer | Body: `{transaction_id}` |
| POST | `/api/autopilot/undo` | Bearer | Body: `{split_id}` |
| GET | `/api/autopilot/undo-context` | Bearer | Motivational message |
| POST | `/api/squad/` | Bearer | Create squad |
| POST | `/api/squad/join` | Bearer | Join via invite code |
| GET | `/api/squad/{id}` | Bearer | Squad details |
| POST | `/api/squad/{id}/rally` | Bearer | Send encouragement nudge |
| WS | `/ws?token=` | JWT param | Real-time events |

*Some routes use `user_id` query param instead of Bearer — auth is mixed across the backend.

---

## Security notes

- **Never commit `backend/.env`** — it contains Supabase keys and GLM credentials.
- **Never paste a Supabase service role key** into Developer Settings — use only user JWTs.
- Bearer tokens are stored in `SharedPreferences` (device-local, not synced).
- Tokens are masked in all log output and UI display.
- Developer Settings is only accessible via a manual tap flow — it is not linked from any onboarding screen.

---

## Demo flow

1. Launch → GXBank entry screen → tap **Open GXBuddy**.
2. Home screen shows mascot in **alert** state (78% food budget used).
3. **Spend RM100 Shopping** → 10-second risk modal → Round Up / Cancel / Continue.
4. **Receive Salary** → cinematic autopilot splits RM1,200 → 60-second undo toast.
5. **Squad** tab → Send Hold Strong → Streak Shield modal.
6. **Pockets** → Configure Autopilot sheet.
7. **Profile** → toggle notifications, privacy settings, open Developer Settings.

## License

This project is developed for the UTM Hackathon.

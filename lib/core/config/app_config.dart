/// Compile-time configuration injected via --dart-define at build time.
///
/// Usage:
///   flutter run \
///     --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
///     --dart-define=WS_URL=ws://10.0.2.2:8000/ws \
///     --dart-define=USE_MOCK_DATA=false \
///     --dart-define=DEV_USER_ID=your-supabase-uuid \
///     --dart-define=DEV_TOKEN=your-supabase-jwt
///
/// When omitted, defaults target the Android emulator (10.0.2.2 → host machine).
abstract final class AppConfig {
  static const String appName = 'GXBuddy';
  static const String appVersion = '1.0.0';

  /// HTTP base URL for all REST calls.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Full WebSocket URL including the /ws path segment.
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://10.0.2.2:8000/ws',
  );

  /// When true the app uses MockGxRepository — no network calls are made.
  static const bool useMockData = bool.fromEnvironment(
    'USE_MOCK_DATA',
    defaultValue: false,
  );

  /// Test user UUID used in debug/dev mode when no JWT is available.
  /// The backend accepts this via X-Dev-User-Id header when DEBUG=true.
  static const String devUserId = String.fromEnvironment(
    'DEV_USER_ID',
    defaultValue: '464f572b-0abc-4317-a36c-4739a0a375ec',
  );

  /// Supabase JWT injected at run-time for production auth.
  /// When empty, debug mode falls back to X-Dev-User-Id header bypass.
  static const String devToken = String.fromEnvironment(
    'DEV_TOKEN',
    defaultValue: '',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

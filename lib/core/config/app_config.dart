/// Compile-time configuration injected via --dart-define at build time.
///
/// Usage:
///   flutter run \
///     --dart-define=API_BASE_URL=http://192.168.1.10:8000 \
///     --dart-define=WS_URL=ws://192.168.1.10:8000/ws \
///     --dart-define=USE_MOCK_DATA=false
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

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

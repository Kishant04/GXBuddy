import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/config/app_config.dart';
import '../core/realtime/websocket_service.dart';
import '../core/storage/auth_token_store.dart';

/// Holds the pre-initialized [AuthTokenStore] for the app lifetime.
///
/// The real instance is created in main.dart (after awaiting [AuthTokenStore.init])
/// and supplied via ProviderScope overrides:
///
///   ProviderScope(
///     overrides: [authTokenStoreProvider.overrideWithValue(tokenStore)],
///     child: const GXBuddyApp(),
///   )
final authTokenStoreProvider = Provider<AuthTokenStore>((ref) {
  // Fallback: used in unit tests that do not supply an override.
  return AuthTokenStore();
});

/// Dio-based HTTP client wired to the persisted token and URL override.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStore: ref.watch(authTokenStoreProvider));
});

/// WebSocket service that connects with the persisted token.
final wsServiceProvider = Provider<WebSocketService>((ref) {
  return WebSocketService(tokenStore: ref.watch(authTokenStoreProvider));
});

/// Reads the currently authenticated user's ID from the token store.
/// Returns null when no session is active.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authTokenStoreProvider).userId;
});

/// True when the app is operating in mock mode (no real network calls).
/// Combines the compile-time flag and any runtime override set via the store.
final isMockModeProvider = Provider<bool>((ref) {
  final override = ref.watch(authTokenStoreProvider).mockModeOverride;
  return override ?? AppConfig.useMockData;
});

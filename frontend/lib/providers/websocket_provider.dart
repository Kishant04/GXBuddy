import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/realtime/realtime_event.dart';
import 'app_providers.dart';
import 'repository_provider.dart';

/// Live WebSocket stream.
///
/// Returns an empty stream when:
///   - mock mode is active (no real server)
///   - no auth token is present
///
/// The stream never throws — connection errors are swallowed by
/// [WebSocketService] and simply close the stream.
final realtimeProvider = StreamProvider<RealtimeEvent>((ref) {
  final isMock = ref.watch(isMockModeProvider);
  final hasToken = ref.watch(authTokenStoreProvider).hasToken;

  if (isMock || !hasToken) return const Stream.empty();

  return ref.watch(repositoryProvider).connectRealtime();
});

/// Holds the most-recent streak_shield event so the squad screen can react.
/// Set by [AppShell]'s WebSocket listener; cleared after the modal is shown.
final wsStreakShieldEventProvider = StateProvider<RealtimeEvent?>((_) => null);

/// Holds the most-recent rally event so the squad screen can show a toast.
final wsRallyEventProvider = StateProvider<RealtimeEvent?>((_) => null);

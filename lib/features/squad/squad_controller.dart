import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/squad_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/repository_provider.dart';

// ─── Squad ID state ────────────────────────────────────────────────────────────

/// In-session squad ID. Populated after create/join.
/// Persisted across restarts via AuthTokenStore.
final squadIdStateProvider = StateProvider<String?>((ref) {
  return ref.watch(authTokenStoreProvider).squadId;
});

/// Resolved squad ID — uses demo ID in mock mode as fallback.
final resolvedSquadIdProvider = Provider<String?>((ref) {
  final stored = ref.watch(squadIdStateProvider);
  if (stored != null && stored.isNotEmpty) return stored;
  if (ref.watch(isMockModeProvider)) return 'sq001';
  return null;
});

// ─── Async squad notifier ─────────────────────────────────────────────────────

class SquadNotifier extends AsyncNotifier<SquadModel?> {
  @override
  Future<SquadModel?> build() => _load();

  Future<SquadModel?> _load() async {
    final squadId = ref.read(resolvedSquadIdProvider);
    if (squadId == null) return null;
    return ref.read(repositoryProvider).getSquad(squadId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<String?> createSquad({
    required String name,
    required String goalName,
    required double goalAmount,
    required DateTime deadline,
  }) async {
    try {
      final squadId = await ref.read(repositoryProvider).createSquad(
            SquadCreate(
              name: name,
              goalName: goalName,
              goalAmount: goalAmount,
              deadline: deadline,
            ),
          );
      // Persist the new squad ID
      await ref.read(authTokenStoreProvider).setSquadId(squadId);
      ref.read(squadIdStateProvider.notifier).state = squadId;
      ref.invalidateSelf();
      return squadId;
    } catch (_) {
      return null;
    }
  }

  Future<String?> joinSquad(String inviteCode) async {
    try {
      final squadId = await ref.read(repositoryProvider).joinSquad(inviteCode);
      await ref.read(authTokenStoreProvider).setSquadId(squadId);
      ref.read(squadIdStateProvider.notifier).state = squadId;
      ref.invalidateSelf();
      return squadId;
    } catch (_) {
      return null;
    }
  }

  Future<bool> sendRally(int targetMemberIndex) async {
    final squad = state.valueOrNull;
    if (squad == null) return false;
    try {
      await ref.read(repositoryProvider).sendRally(
            squadId: squad.id,
            targetMemberIndex: targetMemberIndex,
          );
      return true;
    } catch (_) {
      return false;
    }
  }
}

final squadNotifierProvider =
    AsyncNotifierProvider<SquadNotifier, SquadModel?>(SquadNotifier.new);

// ─── Backward-compat alias (used by existing imports) ─────────────────────────

/// Re-export for code that still references `squadProvider`.
/// Returns the squad or null — screens should migrate to [squadNotifierProvider].
final squadProvider = Provider<SquadModel?>((ref) {
  return ref.watch(squadNotifierProvider).valueOrNull;
});

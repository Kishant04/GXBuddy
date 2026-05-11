import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/squad_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/repository_provider.dart';
import '../../providers/user_id_provider.dart';

import '../profile/profile_controller.dart';

// ─── Squad ID state ────────────────────────────────────────────────────────────

/// In-session squad ID. Populated after create/join or from profile.
/// Persisted across restarts via AuthTokenStore.
final squadIdStateProvider = StateProvider<String?>((ref) {
  final profileSquadId = ref.watch(profileProvider).squadId;
  if (profileSquadId != null && profileSquadId.isNotEmpty) {
    return profileSquadId;
  }
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
    final repo = ref.read(repositoryProvider);
    final userId = ref.read(resolvedUserIdProvider);
    final isMock = ref.read(isMockModeProvider);

    if (userId != null && !isMock) {
      try {
        debugPrint('[SQUAD] Loading squad for user: $userId');
        final squad = await repo.getSquadByUserId(userId);
        debugPrint(
            '[SQUAD] Loaded squad: ${squad.name}, members: ${squad.members.length}');
        // Sync the local state provider so other parts of the app know the ID
        Future.microtask(() {
          ref.read(squadIdStateProvider.notifier).state = squad.id;
        });
        return squad;
      } catch (e) {
        debugPrint('[SQUAD] Error loading squad by user ID: $e');
        // Fall through to other methods
      }
    }

    // 1. Try discovery (GET /api/squad/my)
    if (!isMock) {
      try {
        debugPrint('[SQUAD] Starting discovery...');
        final squad = await repo.getMySquad();
        debugPrint(
            '[SQUAD] Discovered squad: ${squad.name}, members: ${squad.members.length}');
        // Sync the local state provider so other parts of the app know the ID
        Future.microtask(() {
          ref.read(squadIdStateProvider.notifier).state = squad.id;
        });
        return squad;
      } catch (e) {
        debugPrint('[SQUAD] Discovery error: $e');
        // If it's a 404, the user is just not in a squad. Fall through.
        if (e.toString().contains('404')) {
          debugPrint('[SQUAD] User not in any squad (404)');
        } else {
          // For other errors (500, etc.), rethrow so UI shows ErrorState
          rethrow;
        }
      }
    }
    // 2. Fallback to cached ID if discovery failed or in mock mode
    final squadId = ref.read(resolvedSquadIdProvider);
    debugPrint('[SQUAD] Falling back to resolved squad ID: $squadId');
    if (squadId == null) {
      return null;
    }

    try {
      final squad = await repo.getSquad(squadId);
      debugPrint(
          '[SQUAD] Loaded fallback squad: ${squad.name}, members: ${squad.members.length}');
      return squad;
    } catch (e) {
      debugPrint('[SQUAD] Error loading fallback squad $squadId: $e');
      return null;
    }
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
    final userId = ref.read(resolvedUserIdProvider);
    try {
      if (kDebugMode) debugPrint('[SQUAD] Creating squad: $name');
      final squadId = await ref.read(repositoryProvider).createSquad(
            SquadCreate(
              name: name,
              goalName: goalName,
              goalAmount: goalAmount,
              deadline: deadline,
            ),
            userId: userId,
          );

      if (squadId.isEmpty) return null;

      // Update local state and trigger refresh
      await ref.read(authTokenStoreProvider).setSquadId(squadId);
      ref.read(squadIdStateProvider.notifier).state = squadId;
      ref.invalidateSelf();
      return squadId;
    } catch (e) {
      if (kDebugMode) debugPrint('[SQUAD] Error creating squad: $e');
      return null;
    }
  }

  Future<String?> joinSquad(String inviteCode) async {
    final userId = ref.read(resolvedUserIdProvider);
    try {
      if (kDebugMode) {
        debugPrint('[SQUAD] Joining squad with code: $inviteCode');
      }
      final squadId =
          await ref.read(repositoryProvider).joinSquad(inviteCode, userId: userId);

      if (squadId.isEmpty) {
        return null;
      }

      await ref.read(authTokenStoreProvider).setSquadId(squadId);
      ref.read(squadIdStateProvider.notifier).state = squadId;
      ref.invalidateSelf();
      return squadId;
    } catch (e) {
      if (kDebugMode) debugPrint('[SQUAD] Error joining squad: $e');
      return null;
    }
  }

  Future<bool> sendRally(int targetMemberIndex) async {
    final squad = state.valueOrNull;
    final userId = ref.read(resolvedUserIdProvider);
    if (squad == null) return false;
    try {
      await ref.read(repositoryProvider).sendRally(
            squadId: squad.id,
            targetMemberIndex: targetMemberIndex,
            userId: userId,
          );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SQUAD] Error sending rally: $e');
      }
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/autopilot_rule.dart';
import '../../models/pocket_model.dart';
import '../../providers/repository_provider.dart';
import '../../providers/user_id_provider.dart';
import '../home/home_controller.dart';
import '../profile/profile_controller.dart';
import '../squad/squad_controller.dart';

// ─── Async pockets (from repository) ─────────────────────────────────────────

class PocketsNotifier extends AsyncNotifier<List<PocketModel>> {
  @override
  Future<List<PocketModel>> build() => _load();

  Future<List<PocketModel>> _load() {
    final userId = ref.read(resolvedUserIdProvider);
    return ref.read(repositoryProvider).getPockets(userId: userId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
    ref.invalidate(autopilotProvider);
  }

  Future<bool> createPocket({
    required String name,
    required double target,
    SplitRule? splitRule,
  }) async {
    final userId = ref.read(resolvedUserIdProvider);
    try {
      await ref.read(repositoryProvider).createPocket(
            PocketCreate(
              name: name,
              target: target,
              splitRule:
                  splitRule ?? const SplitRule(type: 'percent', value: 0),
            ),
            userId: userId,
          );
      await refresh();
      // Also refresh dashboard and profile to reflect new pocket/totals
      ref.invalidate(homeDashboardProvider);
      ref.invalidate(profileProvider);
      ref.invalidate(squadNotifierProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updatePocket(String pocketId, PocketCreate request) async {
    final userId = ref.read(resolvedUserIdProvider);
    try {
      await ref.read(repositoryProvider).updatePocket(pocketId, request, userId: userId);
      await refresh();
      ref.invalidate(homeDashboardProvider);
      ref.invalidate(profileProvider);
      ref.invalidate(squadNotifierProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deletePocket(String pocketId) async {
    final userId = ref.read(resolvedUserIdProvider);
    try {
      await ref.read(repositoryProvider).deletePocket(pocketId, userId: userId);
      await refresh();
      ref.invalidate(homeDashboardProvider);
      ref.invalidate(profileProvider);
      ref.invalidate(squadNotifierProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final pocketsAsyncProvider =
    AsyncNotifierProvider<PocketsNotifier, List<PocketModel>>(
  PocketsNotifier.new,
);

// ─── Autopilot config (from API and derived from pockets) ───────────────────

class AutopilotNotifier extends AsyncNotifier<AutopilotRule> {
  @override
  Future<AutopilotRule> build() => _load();

  Future<AutopilotRule> _load() async {
    final userId = ref.read(resolvedUserIdProvider);
    final config = await ref.read(repositoryProvider).getAutopilotConfig(userId: userId);
    final pockets = await ref.read(repositoryProvider).getPockets(userId: userId);

    // Filter pockets that have a split rule
    final allocations = pockets
        .where((p) => (p.splitRule?.value ?? 0) > 0)
        .map((p) => PocketAllocation(
              pocketName: p.name,
              value: p.splitRule!.value,
              icon: p.icon,
              colorHex: p.colorHex,
            ))
        .toList();

    return AutopilotRule(
      threshold: config.salaryThreshold,
      incomeType: config.incomeType,
      splitRule:
          SplitRuleType.percent, // Backend logic for multi-pocket is percent
      allocations: allocations,
    );
  }

  Future<void> saveConfig(AutopilotConfig config) async {
    final userId = ref.read(resolvedUserIdProvider);
    await ref.read(repositoryProvider).updateAutopilotConfig(config, userId: userId);
    ref.invalidateSelf();
    ref.invalidate(profileProvider);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

final autopilotProvider =
    AsyncNotifierProvider<AutopilotNotifier, AutopilotRule>(
  AutopilotNotifier.new,
);

class AutopilotEditorNotifier extends StateNotifier<AutopilotRule> {
  AutopilotEditorNotifier(AutopilotRule initial) : super(initial);

  void setThreshold(double v) => state = state.copyWith(threshold: v);
  void setIncomeType(IncomeType t) => state = state.copyWith(incomeType: t);
  void setSplitRule(SplitRuleType r) => state = state.copyWith(splitRule: r);
}

final autopilotEditorProvider =
    StateNotifierProvider.autoDispose<AutopilotEditorNotifier, AutopilotRule>(
        (ref) {
  final current = ref.watch(autopilotProvider).valueOrNull ??
      const AutopilotRule(
          threshold: 800,
          incomeType: IncomeType.monthly,
          splitRule: SplitRuleType.percent,
          allocations: []);
  return AutopilotEditorNotifier(current);
});

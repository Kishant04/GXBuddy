import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/autopilot_rule.dart';
import '../../models/pocket_model.dart';
import '../../providers/repository_provider.dart';
import '../home/home_controller.dart';

// ─── Async pockets (from repository) ─────────────────────────────────────────

class PocketsNotifier extends AsyncNotifier<List<PocketModel>> {
  @override
  Future<List<PocketModel>> build() => _load();

  Future<List<PocketModel>> _load() =>
      ref.read(repositoryProvider).getPockets();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

final pocketsAsyncProvider =
    AsyncNotifierProvider<PocketsNotifier, List<PocketModel>>(
  PocketsNotifier.new,
);

// ─── Autopilot config (local UI state — not yet from API) ─────────────────────

/// Reads autopilot from the backward-compat appStateProvider.
/// Will be replaced once the budget/autopilot endpoint is wired.
final autopilotProvider =
    Provider((ref) => ref.watch(appStateProvider).autopilot);

class AutopilotEditorNotifier extends StateNotifier<AutopilotRule> {
  AutopilotEditorNotifier(AutopilotRule initial) : super(initial);

  void setThreshold(double v) => state = state.copyWith(threshold: v);
  void setIncomeType(IncomeType t) => state = state.copyWith(incomeType: t);
  void setSplitRule(SplitRuleType r) => state = state.copyWith(splitRule: r);
}

final autopilotEditorProvider =
    StateNotifierProvider.autoDispose<AutopilotEditorNotifier, AutopilotRule>(
        (ref) {
  final current = ref.read(autopilotProvider);
  return AutopilotEditorNotifier(current);
});

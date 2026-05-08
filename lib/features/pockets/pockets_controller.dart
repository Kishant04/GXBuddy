import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/autopilot_rule.dart';
import '../home/home_controller.dart';

final pocketsProvider = Provider((ref) => ref.watch(appStateProvider).pockets);

final autopilotProvider = Provider((ref) => ref.watch(appStateProvider).autopilot);

class AutopilotEditorNotifier extends StateNotifier<AutopilotRule> {
  AutopilotEditorNotifier(AutopilotRule initial) : super(initial);

  void setThreshold(double v) => state = state.copyWith(threshold: v);
  void setIncomeType(IncomeType t) => state = state.copyWith(incomeType: t);
  void setSplitRule(SplitRuleType r) => state = state.copyWith(splitRule: r);
}

final autopilotEditorProvider =
    StateNotifierProvider.autoDispose<AutopilotEditorNotifier, AutopilotRule>((ref) {
  final current = ref.read(autopilotProvider);
  return AutopilotEditorNotifier(current);
});

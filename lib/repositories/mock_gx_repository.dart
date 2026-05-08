import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/dashboard_response.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/pocket.dart';
import '../models/squad.dart';
import '../models/autopilot_rule.dart';
import '../models/user.dart';
import '../core/realtime/realtime_event.dart';
import '../shared/constants/demo_data.dart';
import 'gx_repository.dart';

/// All data comes from DemoData — no network calls.
class MockGxRepository implements GxRepository {
  final _realtimeController = StreamController<RealtimeEvent>.broadcast();

  @override
  Future<UserModel> getUser() async {
    await _delay();
    return DemoData.user;
  }

  @override
  Future<DashboardResponse> getDashboard() async {
    await _delay();
    return DashboardResponse(
      mascot: DemoData.initialMascot,
      weeklyBudget: DemoData.initialBudget,
      pockets: List.unmodifiable(DemoData.initialPockets),
      activeAlerts: DemoData.activeAlerts,
      upcomingBills: DemoData.upcomingBills,
    );
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    await _delay();
    return List.unmodifiable(DemoData.initialTransactions);
  }

  @override
  Future<WeeklyBudget> getBudgets() async {
    await _delay();
    return DemoData.initialBudget;
  }

  @override
  Future<List<PocketModel>> getPockets() async {
    await _delay();
    return List.unmodifiable(DemoData.initialPockets);
  }

  @override
  Future<AutopilotSplitResult> triggerAutopilot() async {
    await _delay();
    return AutopilotSplitResult(
      splitId: 'split_${DateTime.now().millisecondsSinceEpoch}',
      totalAmount: DemoData.totalSalarySplit,
      splits: const [
        SplitEntry(pocketName: 'Emergency Fund', amount: 240),
        SplitEntry(pocketName: 'PTPTN', amount: 120),
        SplitEntry(pocketName: 'Travel', amount: 60),
      ],
    );
  }

  @override
  Future<void> undoAutopilot(String splitId) async {
    await _delay();
    debugPrint('MockRepo: undo split $splitId');
  }

  @override
  Future<SquadModel> getSquad(String squadId) async {
    await _delay();
    return DemoData.initialSquad;
  }

  @override
  Future<void> sendRally(String squadId, String memberId) async {
    await _delay();
    _realtimeController.add(RealtimeEvent(
      type: RealtimeEventType.rally,
      data: {'from_member_index': 0, 'message': 'Hold Strong 💪'},
    ));
  }

  @override
  Stream<RealtimeEvent> connectRealtime() => _realtimeController.stream;

  Future<void> _delay([Duration d = const Duration(milliseconds: 300)]) => Future.delayed(d);

  void dispose() => _realtimeController.close();
}

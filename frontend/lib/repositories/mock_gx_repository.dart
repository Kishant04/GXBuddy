import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/realtime/realtime_event.dart';
import '../models/alert_model.dart';
import '../models/autopilot_model.dart';
import '../models/autopilot_rule.dart';
import '../models/bill_model.dart';
import '../models/budget_model.dart';
import '../models/dashboard_model.dart';
import '../models/pocket_model.dart';
import '../models/squad_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../shared/constants/demo_data.dart';
import 'gx_repository.dart';

/// All data comes from [DemoData] — no network calls.
/// Maintains an in-memory mutable list for pocket CRUD.
class MockGxRepository implements GxRepository {
  MockGxRepository() : _pockets = List.of(DemoData.initialPockets);

  final _realtimeController = StreamController<RealtimeEvent>.broadcast();
  List<PocketModel> _pockets;

  // ── User ──────────────────────────────────────────────────

  @override
  Future<UserModel> getUser() async {
    await _delay();
    return DemoData.user;
  }

  @override
  Future<UserModel> getUserProfile({String? userId}) async {
    await _delay();
    return DemoData.user;
  }

  @override
  Future<UserModel> updateProfile(UserModel profile) async {
    await _delay();
    return profile;
  }

  @override
  Future<void> resetDemoData({String? userId}) async {
    await _delay();
  }

  // ── Dashboard ─────────────────────────────────────────────

  @override
  Future<DashboardModel> getDashboard({required String userId}) async {
    await _delay();
    return DashboardModel(
      mascot: DemoData.initialMascot,
      weeklySpendTotal: DemoData.initialBudget.totalSpent,
      weeklyBudgetLimit: DemoData.initialBudget.totalBudget,
      weeklyBudgetUsedPercent: DemoData.initialBudget.overallPercent * 100,
      categoryBreakdown: DemoData.initialBudget.categories
          .map((c) => CategorySpendModel(
                category: c.category,
                amount: c.spent,
              ))
          .toList(),
      upcomingBills: DemoData.upcomingBills
          .map((b) => BillModel(
                id: b.id,
                name: b.name,
                amount: b.amount,
                dueDate: DateTime.now().add(Duration(days: b.dueInDays)),
                daysRemaining: b.dueInDays,
                isPaid: false,
              ))
          .toList(),
      recentAlerts: List.of(DemoData.activeAlerts),
      pocketSummaries: DemoData.initialPockets
          .map((p) => PocketSummaryModel(
                id: p.id,
                name: p.name,
                balance: p.balance,
                target: p.target,
                progressPercent: p.percent * 100,
              ))
          .toList(),
      streakSummary: StreakSummaryModel(
        currentStreak: DemoData.user.streakDays,
        bestStreak: DemoData.user.streakDays,
      ),
      recentTransactions: DemoData.initialTransactions.take(5).toList(),
    );
  }

  // ── Transactions ──────────────────────────────────────────

  @override
  Future<List<TransactionModel>> getTransactions({
    required String userId,
    int limit = 30,
  }) async {
    await _delay();
    return DemoData.initialTransactions.take(limit).toList();
  }

  @override
  Future<TransactionResponse> createTransaction(
      TransactionCreateRequest request) async {
    await _delay();
    final tx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      name: request.merchant,
      amount: request.amount,
      category: request.category ?? 'Other',
      riskLabel: 'Safe',
      timestamp: request.timestamp ?? DateTime.now(),
      glyph: '📝',
      colorHex: '#771FFF',
    );
    return TransactionResponse(
      transaction: tx,
      classification: request.category ?? 'OTHER',
      riskScore: 10,
      mascot: DemoData.initialMascot,
    );
  }

  // ── Budgets ───────────────────────────────────────────────

  @override
  Future<List<BudgetModel>> getBudgets({required String userId}) async {
    await _delay();
    final b = DemoData.initialBudget;
    return [
      BudgetModel(
        budgetId: 'budget_overall',
        weeklyLimit: b.totalBudget,
        spentAmount: b.totalSpent,
        usagePercent: b.overallPercent * 100,
      ),
      ...b.categories.map((c) => BudgetModel(
            budgetId: 'budget_${c.category}',
            category: c.category,
            weeklyLimit: c.limit,
            spentAmount: c.spent,
            usagePercent: c.percent * 100,
          )),
    ];
  }

  // ── Bills ─────────────────────────────────────────────────

  @override
  Future<List<BillModel>> getBills({
    required String userId,
    int daysAhead = 7,
  }) async {
    await _delay();
    return DemoData.upcomingBills
        .where((b) => b.dueInDays <= daysAhead)
        .map((b) => BillModel(
              id: b.id,
              name: b.name,
              amount: b.amount,
              dueDate: DateTime.now().add(Duration(days: b.dueInDays)),
              daysRemaining: b.dueInDays,
              isPaid: false,
            ))
        .toList();
  }

  // ── Alerts ────────────────────────────────────────────────

  @override
  Future<List<AlertModel>> getAlerts({
    required String userId,
    String? severity,
    int limit = 20,
  }) async {
    await _delay();
    var alerts = List<AlertModel>.of(DemoData.activeAlerts);
    if (severity != null) {
      final target = AlertModel.severityFromString(severity);
      alerts = alerts.where((a) => a.severity == target).toList();
    }
    return alerts.take(limit).toList();
  }

  @override
  Future<void> markAlertActioned(String alertId) async {
    await _delay();
    debugPrint('MockRepo: alert $alertId marked as actioned');
  }

  // ── Pockets ───────────────────────────────────────────────

  @override
  Future<List<PocketModel>> getPockets({String? userId}) async {
    await _delay();
    return List.unmodifiable(_pockets);
  }

  @override
  Future<PocketModel> createPocket(PocketCreate request, {String? userId}) async {
    await _delay();
    final pocket = PocketModel(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      name: request.name,
      balance: 0,
      target: request.target,
      colorHex: '#1FB287',
      icon: '💰',
      note: PocketModel.buildNote(request.splitRule),
      eta: '',
      splitRule: request.splitRule,
    );
    _pockets = [..._pockets, pocket];
    return pocket;
  }

  @override
  Future<PocketModel> updatePocket(
      String pocketId, PocketCreate request, {String? userId}) async {
    await _delay();
    final index = _pockets.indexWhere((p) => p.id == pocketId);
    if (index < 0) throw Exception('Pocket not found: $pocketId');
    final updated = _pockets[index].copyWith(
      name: request.name,
      target: request.target,
      splitRule: request.splitRule,
      note: PocketModel.buildNote(request.splitRule),
    );
    _pockets = [..._pockets]..[index] = updated;
    return updated;
  }

  @override
  Future<void> deletePocket(String pocketId, {String? userId}) async {
    await _delay();
    _pockets = _pockets.where((p) => p.id != pocketId).toList();
  }

  // ── Autopilot ─────────────────────────────────────────────

  @override
  Future<AutopilotTriggerResponse> triggerAutopilot({
    String? transactionId,
    String? userId,
  }) async {
    await _delay();
    final deadline = DateTime.now().add(const Duration(seconds: 60));
    return AutopilotTriggerResponse(
      splitId: 'split_${DateTime.now().millisecondsSinceEpoch}',
      totalRouted: DemoData.totalSalarySplit,
      lines: const [
        SplitLine(
          pocketId: 'p001',
          pocketName: 'Emergency Fund',
          amount: 240,
          ruleType: 'percent',
          ruleValue: 20,
        ),
        SplitLine(
          pocketId: 'p002',
          pocketName: 'PTPTN',
          amount: 120,
          ruleType: 'percent',
          ruleValue: 10,
        ),
        SplitLine(
          pocketId: 'p003',
          pocketName: 'Travel',
          amount: 60,
          ruleType: 'percent',
          ruleValue: 5,
        ),
      ],
      undoDeadline: deadline,
    );
  }

  @override
  Future<AutopilotUndoResponse> undoAutopilot({required String splitId, String? userId}) async {
    await _delay();
    debugPrint('MockRepo: undo split $splitId');
    return const AutopilotUndoResponse(
      reversed: true,
      message: 'Split reversed. Funds returned to your main account.',
    );
  }

  @override
  Future<String> getUndoContext({String? userId}) async {
    await _delay();
    return 'Every ringgit saved today is a step towards freedom. Are you sure?';
  }

  @override
  Future<AutopilotConfig> getAutopilotConfig({String? userId}) async {
    await _delay();
    return const AutopilotConfig(
        salaryThreshold: 800, incomeType: IncomeType.monthly);
  }

  @override
  Future<AutopilotConfig> updateAutopilotConfig(AutopilotConfig config, {String? userId}) async {
    await _delay();
    return config;
  }

  // ── Squad ─────────────────────────────────────────────────

  @override
  Future<String> createSquad(SquadCreate request, {String? userId}) async {
    await _delay();
    return 'sq_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<String> joinSquad(String inviteCode, {String? userId}) async {
    await _delay();
    return DemoData.initialSquad.id;
  }

  @override
  Future<SquadModel> getSquad(String squadId, {String? userId}) async {
    await _delay();
    return DemoData.initialSquad;
  }

  @override
  Future<SquadModel> getMySquad() async {
    await _delay();
    return DemoData.initialSquad;
  }

  @override
  Future<SquadModel> getSquadByUserId(String userId) async {
    await _delay();
    return DemoData.initialSquad;
  }

  @override
  Future<void> sendRally({
    required String squadId,
    required int targetMemberIndex,
    String? userId,
  }) async {
    await _delay();
    _realtimeController.add(RealtimeEvent(
      type: RealtimeEventType.rally,
      data: {
        'member_index': targetMemberIndex,
        'squad_id': squadId,
        'message': 'Hold Strong 💪',
      },
    ));
  }

  // ── Insights ──────────────────────────────────────────────

  @override
  Future<String> getSpendInsight({required String userId}) async {
    await _delay();
    return 'Food spending is your biggest category this week. '
        'Try cooking at home once more to save RM30. 🍳';
  }

  // ── Realtime ──────────────────────────────────────────────

  @override
  Stream<RealtimeEvent> connectRealtime() => _realtimeController.stream;

  // ── Internals ─────────────────────────────────────────────

  Future<void> _delay([Duration d = const Duration(milliseconds: 300)]) =>
      Future.delayed(d);

  void dispose() => _realtimeController.close();
}

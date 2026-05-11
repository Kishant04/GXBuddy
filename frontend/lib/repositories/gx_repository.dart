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

/// Abstract contract between the UI and the data layer.
///
/// Switch implementations by changing [repositoryProvider] in
/// lib/providers/repository_provider.dart.
abstract class GxRepository {
  // ── User / Profile ────────────────────────────────────────
  Future<UserModel> getUser();
  Future<UserModel> getUserProfile({String? userId});
  Future<UserModel> updateProfile(UserModel profile);
  Future<void> resetDemoData({String? userId});

  // ── Dashboard ─────────────────────────────────────────────
  Future<DashboardModel> getDashboard({required String userId});

  // ── Transactions ──────────────────────────────────────────
  Future<List<TransactionModel>> getTransactions({
    required String userId,
    int limit = 30,
  });

  Future<TransactionResponse> createTransaction(
      TransactionCreateRequest request);

  // ── Budgets ───────────────────────────────────────────────
  Future<List<BudgetModel>> getBudgets({required String userId});

  // ── Bills ─────────────────────────────────────────────────
  Future<List<BillModel>> getBills({
    required String userId,
    int daysAhead = 7,
  });

  // ── Alerts ────────────────────────────────────────────────
  Future<List<AlertModel>> getAlerts({
    required String userId,
    String? severity,
    int limit = 20,
  });

  Future<void> markAlertActioned(String alertId);

  // ── Pockets ───────────────────────────────────────────────
  Future<List<PocketModel>> getPockets({String? userId});
  Future<PocketModel> createPocket(PocketCreate request, {String? userId});
  Future<PocketModel> updatePocket(String pocketId, PocketCreate request,
      {String? userId});
  Future<void> deletePocket(String pocketId, {String? userId});

  // ── Autopilot ─────────────────────────────────────────────
  Future<AutopilotTriggerResponse> triggerAutopilot({
    String? transactionId,
    String? userId,
  });
  Future<AutopilotUndoResponse> undoAutopilot({
    required String splitId,
    String? userId,
  });
  Future<String> getUndoContext({String? userId});
  Future<AutopilotConfig> getAutopilotConfig({String? userId});
  Future<AutopilotConfig> updateAutopilotConfig(AutopilotConfig config,
      {String? userId});

  // ── Squad ─────────────────────────────────────────────────
  Future<String> createSquad(SquadCreate request, {String? userId});
  Future<String> joinSquad(String inviteCode, {String? userId});
  Future<SquadModel> getSquad(String squadId, {String? userId});
  Future<SquadModel> getMySquad();
  Future<SquadModel> getSquadByUserId(String userId);
  Future<void> sendRally({
    required String squadId,
    required int targetMemberIndex,
    String? userId,
  });

  // ── Insights ──────────────────────────────────────────────
  /// Returns AI-generated spend insight text for the current week.
  Future<String> getSpendInsight({required String userId});

  // ── Realtime ──────────────────────────────────────────────
  Stream<RealtimeEvent> connectRealtime();
}

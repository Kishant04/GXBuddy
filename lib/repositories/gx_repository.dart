import '../core/realtime/realtime_event.dart';
import '../models/alert_model.dart';
import '../models/autopilot_model.dart';
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
  Future<UserModel> getUserProfile();
  Future<UserModel> updateProfile(UserModel profile);

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
  Future<List<PocketModel>> getPockets();
  Future<PocketModel> createPocket(PocketCreate request);
  Future<PocketModel> updatePocket(String pocketId, PocketCreate request);
  Future<void> deletePocket(String pocketId);

  // ── Autopilot ─────────────────────────────────────────────
  Future<AutopilotTriggerResponse> triggerAutopilot({
    required String transactionId,
  });

  Future<AutopilotUndoResponse> undoAutopilot({required String splitId});

  Future<String> getUndoContext();

  // ── Squad ─────────────────────────────────────────────────
  Future<String> createSquad(SquadCreate request);
  Future<String> joinSquad(String inviteCode);
  Future<SquadModel> getSquad(String squadId);
  Future<void> sendRally({
    required String squadId,
    required int targetMemberIndex,
  });

  // ── Insights ──────────────────────────────────────────────
  /// Returns AI-generated spend insight text for the current week.
  Future<String> getSpendInsight({required String userId});

  // ── Realtime ──────────────────────────────────────────────
  Stream<RealtimeEvent> connectRealtime();
}

import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/realtime/realtime_event.dart';
import '../core/realtime/websocket_service.dart';
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
import 'gx_repository.dart';

/// Production repository — makes real HTTP calls via [ApiClient].
///
/// Activate by changing [isMockModeProvider] to false or setting
/// USE_MOCK_DATA=false at build time.
class ApiGxRepository implements GxRepository {
  ApiGxRepository({required this.apiClient, required this.wsService});

  final ApiClient apiClient;
  final WebSocketService wsService;

  // ── User / Profile ────────────────────────────────────────

  @override
  Future<UserModel> getUser() => apiClient.get(
        Endpoints.authMe,
        fromJson: (d) {
          final map = d as Map<String, dynamic>;
          final inner = map['user'] as Map<String, dynamic>? ?? map;
          return UserModel.fromJson(inner);
        },
      );

  @override
  Future<UserModel> getUserProfile({String? userId}) => apiClient.get(
        Endpoints.userProfile,
        queryParameters: userId != null ? {'user_id': userId} : null,
        fromJson: (d) => UserModel.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<UserModel> updateProfile(UserModel profile) => apiClient.patch(
        Endpoints.userProfile,
        data: {
          'name': profile.name,
          'monthly_income': profile.monthlyIncome,
          'push_enabled': profile.pushEnabled,
          'whatsapp_enabled': profile.whatsappEnabled,
          'telegram_enabled': profile.telegramEnabled,
          'anonymous_squad': profile.anonymousSquad,
          'hide_balances': profile.hideBalances,
          'card_frozen': profile.cardFrozen,
          'weekly_spending_limit': profile.weeklySpendingLimit,
        },
        fromJson: (d) => UserModel.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<void> resetDemoData({String? userId}) => apiClient.post(
        Endpoints.demoReset,
        data: userId != null ? {'user_id': userId} : {},
      );

  // ── Dashboard ─────────────────────────────────────────────

  @override
  Future<DashboardModel> getDashboard({required String userId}) =>
      apiClient.get(
        Endpoints.dashboard,
        queryParameters: {'user_id': userId},
        fromJson: (d) => DashboardModel.fromJson(d as Map<String, dynamic>),
      );

  // ── Transactions ──────────────────────────────────────────

  @override
  Future<List<TransactionModel>> getTransactions({
    required String userId,
    int limit = 30,
  }) =>
      apiClient.get(
        Endpoints.transactions,
        queryParameters: {'user_id': userId, 'limit': limit},
        fromJson: (d) {
          final map = d as Map<String, dynamic>;
          final items = map['items'] as List<dynamic>? ?? [];
          return items
              .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

  @override
  Future<TransactionResponse> createTransaction(
          TransactionCreateRequest request) =>
      apiClient.post(
        Endpoints.transactions,
        data: request.toJson(),
        fromJson: (d) =>
            TransactionResponse.fromJson(d as Map<String, dynamic>),
      );

  // ── Budgets ───────────────────────────────────────────────

  @override
  Future<List<BudgetModel>> getBudgets({required String userId}) =>
      apiClient.get(
        Endpoints.budgets,
        queryParameters: {'user_id': userId},
        fromJson: (d) {
          final map = d as Map<String, dynamic>;
          final items = map['items'] as List<dynamic>? ?? [];
          return items
              .map((e) => BudgetModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

  // ── Bills ─────────────────────────────────────────────────

  @override
  Future<List<BillModel>> getBills({
    required String userId,
    int daysAhead = 7,
  }) =>
      apiClient.get(
        Endpoints.bills,
        queryParameters: {
          'user_id': userId,
          'days_ahead': daysAhead,
        },
        fromJson: (d) {
          final map = d as Map<String, dynamic>;
          final items = map['upcoming_bills'] as List<dynamic>? ?? [];
          return items
              .map((e) => BillModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

  // ── Alerts ────────────────────────────────────────────────

  @override
  Future<List<AlertModel>> getAlerts({
    required String userId,
    String? severity,
    int limit = 20,
  }) =>
      apiClient.get(
        Endpoints.alerts,
        queryParameters: {
          'user_id': userId,
          if (severity != null) 'severity': severity,
          'limit': limit,
        },
        fromJson: (d) {
          final map = d as Map<String, dynamic>;
          final items = map['items'] as List<dynamic>? ?? [];
          return items
              .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

  @override
  Future<void> markAlertActioned(String alertId) =>
      apiClient.post(Endpoints.alertAction(alertId));

  // ── Pockets ───────────────────────────────────────────────

  @override
  Future<List<PocketModel>> getPockets({String? userId}) => apiClient.get(
        Endpoints.pockets,
        queryParameters: userId != null ? {'user_id': userId} : null,
        fromJson: (d) => (d as List<dynamic>)
            .map((e) => PocketModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  Future<PocketModel> createPocket(PocketCreate request, {String? userId}) =>
      apiClient.post(
        Endpoints.pockets,
        queryParameters: userId != null ? {'user_id': userId} : null,
        data: request.toJson(),
        fromJson: (d) => PocketModel.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<PocketModel> updatePocket(String pocketId, PocketCreate request,
          {String? userId}) =>
      apiClient.patch(
        Endpoints.pocket(pocketId),
        queryParameters: userId != null ? {'user_id': userId} : null,
        data: request.toJson(),
        fromJson: (d) => PocketModel.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<void> deletePocket(String pocketId, {String? userId}) =>
      apiClient.delete(
        Endpoints.pocket(pocketId),
        // queryParameters: userId != null ? {'user_id': userId} : null, // Dio's delete doesn't take queryParams in this wrapper yet
      );

  // ── Autopilot ─────────────────────────────────────────────

  @override
  Future<AutopilotTriggerResponse> triggerAutopilot({
    String? transactionId,
    String? userId,
  }) =>
      apiClient.post(
        Endpoints.autopilotTrigger,
        data: {
          if (transactionId != null) 'transaction_id': transactionId,
          if (userId != null) 'user_id': userId,
        },
        fromJson: (d) =>
            AutopilotTriggerResponse.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<AutopilotUndoResponse> undoAutopilot({
    required String splitId,
    String? userId,
  }) =>
      apiClient.post(
        Endpoints.autopilotUndo,
        data: {
          'split_id': splitId,
          if (userId != null) 'user_id': userId,
        },
        fromJson: (d) =>
            AutopilotUndoResponse.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<String> getUndoContext({String? userId}) => apiClient.get(
        Endpoints.autopilotUndoContext,
        queryParameters: userId != null ? {'user_id': userId} : null,
        fromJson: (d) =>
            (d as Map<String, dynamic>)['message'] as String? ?? '',
      );

  @override
  Future<AutopilotConfig> getAutopilotConfig({String? userId}) => apiClient.get(
        '${Endpoints.autopilotTrigger.replaceAll('/trigger', '')}/config',
        queryParameters: userId != null ? {'user_id': userId} : null,
        fromJson: (d) => AutopilotConfig.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<AutopilotConfig> updateAutopilotConfig(AutopilotConfig config,
          {String? userId}) =>
      apiClient.patch(
        '${Endpoints.autopilotTrigger.replaceAll('/trigger', '')}/config',
        queryParameters: userId != null ? {'user_id': userId} : null,
        data: config.toJson(),
        fromJson: (d) => AutopilotConfig.fromJson(d as Map<String, dynamic>),
      );

  // ── Squad ─────────────────────────────────────────────────

  @override
  Future<String> createSquad(SquadCreate request, {String? userId}) =>
      apiClient.post(
        Endpoints.squadCreate,
        queryParameters: userId != null ? {'user_id': userId} : null,
        data: request.toJson(),
        fromJson: (d) =>
            (d as Map<String, dynamic>)['squad_id'] as String? ?? '',
      );

  @override
  Future<String> joinSquad(String inviteCode, {String? userId}) =>
      apiClient.post(
        Endpoints.squadJoin,
        queryParameters: userId != null ? {'user_id': userId} : null,
        data: {'invite_code': inviteCode},
        fromJson: (d) =>
            (d as Map<String, dynamic>)['squad_id'] as String? ?? '',
      );

  @override
  Future<SquadModel> getSquad(String squadId, {String? userId}) =>
      apiClient.get(
        Endpoints.squad(squadId),
        queryParameters: userId != null ? {'user_id': userId} : null,
        fromJson: (d) => SquadModel.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<SquadModel> getMySquad() => apiClient.get(
        Endpoints.squadMy,
        fromJson: (d) => SquadModel.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<SquadModel> getSquadByUserId(String userId) => apiClient.get(
        Endpoints.squadByUser(userId),
        fromJson: (d) => SquadModel.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<void> sendRally({
    required String squadId,
    required int targetMemberIndex,
    String? userId,
  }) =>
      apiClient.post(
        Endpoints.squadRally(squadId),
        queryParameters: userId != null ? {'user_id': userId} : null,
        data: {'target_member_index': targetMemberIndex},
      );

  // ── Insights ──────────────────────────────────────────────

  @override
  Future<String> getSpendInsight({required String userId}) => apiClient.get(
        Endpoints.spendInsight,
        queryParameters: {'user_id': userId},
        fromJson: (d) {
          final map = d as Map<String, dynamic>;
          return map['insight'] as String? ??
              map['tip'] as String? ??
              'Loading your weekly insight…';
        },
      );

  // ── Realtime ──────────────────────────────────────────────

  @override
  Stream<RealtimeEvent> connectRealtime() => wsService.connect();
}

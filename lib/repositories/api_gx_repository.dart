import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/realtime/realtime_event.dart';
import '../core/realtime/websocket_service.dart';
import '../models/alert_model.dart';
import '../models/autopilot_model.dart';
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

  // ── User ──────────────────────────────────────────────────

  @override
  Future<UserModel> getUser() => apiClient.get(
        Endpoints.authMe,
        fromJson: (d) {
          final map = d as Map<String, dynamic>;
          // GET /api/auth/me returns {user: {id, email}}.
          final inner = map['user'] as Map<String, dynamic>? ?? map;
          return UserModel.fromJson(inner);
        },
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
        '/api/alerts',
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
      apiClient.post('/api/alerts/$alertId/action');

  // ── Pockets ───────────────────────────────────────────────

  @override
  Future<List<PocketModel>> getPockets() => apiClient.get(
        Endpoints.pockets,
        fromJson: (d) => (d as List<dynamic>)
            .map((e) => PocketModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  Future<PocketModel> createPocket(PocketCreate request) => apiClient.post(
        Endpoints.pockets,
        data: request.toJson(),
        fromJson: (d) => PocketModel.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<PocketModel> updatePocket(String pocketId, PocketCreate request) =>
      apiClient.patch(
        Endpoints.pocket(pocketId),
        data: request.toJson(),
        fromJson: (d) => PocketModel.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<void> deletePocket(String pocketId) =>
      apiClient.delete(Endpoints.pocket(pocketId));

  // ── Autopilot ─────────────────────────────────────────────

  @override
  Future<AutopilotTriggerResponse> triggerAutopilot({
    required String transactionId,
  }) =>
      apiClient.post(
        Endpoints.autopilotTrigger,
        data: {'transaction_id': transactionId},
        fromJson: (d) =>
            AutopilotTriggerResponse.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<AutopilotUndoResponse> undoAutopilot({required String splitId}) =>
      apiClient.post(
        Endpoints.autopilotUndo,
        data: {'split_id': splitId},
        fromJson: (d) =>
            AutopilotUndoResponse.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<String> getUndoContext() => apiClient.get(
        Endpoints.autopilotUndoContext,
        fromJson: (d) =>
            (d as Map<String, dynamic>)['message'] as String? ?? '',
      );

  // ── Squad ─────────────────────────────────────────────────

  @override
  Future<String> createSquad(SquadCreate request) => apiClient.post(
        Endpoints.squadCreate,
        data: request.toJson(),
        fromJson: (d) =>
            (d as Map<String, dynamic>)['squad_id'] as String? ?? '',
      );

  @override
  Future<String> joinSquad(String inviteCode) => apiClient.post(
        Endpoints.squadJoin,
        data: {'invite_code': inviteCode},
        fromJson: (d) =>
            (d as Map<String, dynamic>)['squad_id'] as String? ?? '',
      );

  @override
  Future<SquadModel> getSquad(String squadId) => apiClient.get(
        Endpoints.squad(squadId),
        fromJson: (d) => SquadModel.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<void> sendRally({
    required String squadId,
    required int targetMemberIndex,
  }) =>
      apiClient.post(
        Endpoints.squadRally(squadId),
        data: {'target_member_index': targetMemberIndex},
      );

  // ── Realtime ──────────────────────────────────────────────

  @override
  Stream<RealtimeEvent> connectRealtime() => wsService.connect();
}

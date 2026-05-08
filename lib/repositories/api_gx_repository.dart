import '../models/dashboard_response.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/pocket.dart';
import '../models/squad.dart';
import '../models/autopilot_rule.dart';
import '../models/user.dart';
import '../core/api/api_client.dart';
import '../core/api/endpoints.dart';
import '../core/realtime/realtime_event.dart';
import '../core/realtime/websocket_service.dart';
import 'gx_repository.dart';

/// Production repository — NOT active by default.
/// To enable: change the provider in app.dart to use ApiGxRepository.
class ApiGxRepository implements GxRepository {
  ApiGxRepository({required this.apiClient, required this.wsService});

  final ApiClient apiClient;
  final WebSocketService wsService;

  @override
  Future<UserModel> getUser() => apiClient.get(
        Endpoints.profile,
        fromJson: (d) => UserModel.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<DashboardResponse> getDashboard() => apiClient.get(
        Endpoints.dashboard,
        fromJson: (d) => DashboardResponse.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<List<TransactionModel>> getTransactions() => apiClient.get(
        Endpoints.transactions,
        fromJson: (d) => (d as List<dynamic>)
            .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  Future<WeeklyBudget> getBudgets() => apiClient.get(
        Endpoints.budgets,
        fromJson: (d) => WeeklyBudget.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<List<PocketModel>> getPockets() => apiClient.get(
        Endpoints.pockets,
        fromJson: (d) => (d as List<dynamic>)
            .map((e) => PocketModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  Future<AutopilotSplitResult> triggerAutopilot() => apiClient.post(
        Endpoints.autopilotTrigger,
        fromJson: (d) => AutopilotSplitResult.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<void> undoAutopilot(String splitId) => apiClient.post(
        Endpoints.autopilotUndo,
        data: {'split_id': splitId},
      );

  @override
  Future<SquadModel> getSquad(String squadId) => apiClient.get(
        Endpoints.squad(squadId),
        fromJson: (d) => SquadModel.fromJson(d as Map<String, dynamic>),
      );

  @override
  Future<void> sendRally(String squadId, String memberId) => apiClient.post(
        Endpoints.squadRally(squadId),
        data: {'member_id': memberId},
      );

  @override
  Stream<RealtimeEvent> connectRealtime() => wsService.connect();
}

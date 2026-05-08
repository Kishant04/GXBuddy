import '../models/dashboard_response.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/pocket.dart';
import '../models/squad.dart';
import '../models/autopilot_rule.dart';
import '../models/user.dart';
import '../core/realtime/realtime_event.dart';

/// Abstract contract between the UI and the data layer.
/// Switch from MockGxRepository to ApiGxRepository by changing
/// the Riverpod provider in repositories/providers.dart.
abstract class GxRepository {
  Future<UserModel> getUser();
  Future<DashboardResponse> getDashboard();
  Future<List<TransactionModel>> getTransactions();
  Future<WeeklyBudget> getBudgets();
  Future<List<PocketModel>> getPockets();
  Future<AutopilotSplitResult> triggerAutopilot();
  Future<void> undoAutopilot(String splitId);
  Future<SquadModel> getSquad(String squadId);
  Future<void> sendRally(String squadId, String memberId);
  Stream<RealtimeEvent> connectRealtime();
}

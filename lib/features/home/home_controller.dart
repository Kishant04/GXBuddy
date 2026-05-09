import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/autopilot_model.dart';
import '../../models/autopilot_rule.dart';
import '../../models/budget.dart';
import '../../models/dashboard_model.dart';
import '../../models/mascot.dart';
import '../../models/pocket.dart';
import '../../models/transaction_model.dart';
import '../../providers/repository_provider.dart';
import '../../providers/user_id_provider.dart';
import '../../shared/constants/demo_data.dart';

// ─── Async dashboard state (fed by repository) ────────────────────────────────

/// Thrown when no user ID is available and the app is not in mock mode.
class NoUserIdException implements Exception {
  const NoUserIdException();
  @override
  String toString() => 'NoUserIdException: no user ID configured';
}

class HomeDashboardNotifier extends AsyncNotifier<DashboardModel> {
  @override
  Future<DashboardModel> build() => _load();

  Future<DashboardModel> _load() async {
    final userId = ref.read(resolvedUserIdProvider);
    if (userId == null) throw const NoUserIdException();
    return ref.read(repositoryProvider).getDashboard(userId: userId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  /// Calls createTransaction, refreshes the dashboard, returns the response.
  /// Returns null on error (caller should show a toast).
  Future<TransactionResponse?> createTransaction({
    required double amount,
    required String merchant,
    required String category,
  }) async {
    final userId = ref.read(resolvedUserIdProvider) ?? 'demo_user';
    try {
      final result = await ref.read(repositoryProvider).createTransaction(
            TransactionCreateRequest(
              amount: amount,
              merchant: merchant,
              category: category,
              userId: userId,
            ),
          );
      // Refresh so the dashboard reflects the new transaction immediately.
      ref.invalidateSelf();
      return result;
    } catch (_) {
      return null;
    }
  }

  /// Creates a salary transaction then triggers autopilot.
  /// Returns the split result (or null on failure).
  Future<AutopilotTriggerResponse?> receiveSalary(
      {required double salaryAmount}) async {
    final userId = ref.read(resolvedUserIdProvider) ?? 'demo_user';
    try {
      final txResult = await ref.read(repositoryProvider).createTransaction(
            TransactionCreateRequest(
              amount: salaryAmount,
              merchant: 'Salary Credit',
              category: 'SALARY',
              userId: userId,
            ),
          );
      final splitResult = await ref.read(repositoryProvider).triggerAutopilot(
            transactionId: txResult.transaction.id,
          );
      ref.invalidateSelf();
      return splitResult;
    } catch (_) {
      return null;
    }
  }

  Future<bool> undoAutopilot(String splitId) async {
    try {
      final result = await ref.read(repositoryProvider).undoAutopilot(
            splitId: splitId,
          );
      if (result.reversed) ref.invalidateSelf();
      return result.reversed;
    } catch (_) {
      return false;
    }
  }
}

final homeDashboardProvider =
    AsyncNotifierProvider<HomeDashboardNotifier, DashboardModel>(
  HomeDashboardNotifier.new,
);

// ─── Local UI-only state (not from API) ──────────────────────────────────────

class HomeUiState {
  const HomeUiState({
    this.alertsDismissed = false,
    this.pendingAction = false,
    this.lastSplitResult,
  });

  final bool alertsDismissed;
  final bool pendingAction;
  final AutopilotTriggerResponse? lastSplitResult;

  HomeUiState copyWith({
    bool? alertsDismissed,
    bool? pendingAction,
    AutopilotTriggerResponse? lastSplitResult,
    bool clearSplit = false,
  }) =>
      HomeUiState(
        alertsDismissed: alertsDismissed ?? this.alertsDismissed,
        pendingAction: pendingAction ?? this.pendingAction,
        lastSplitResult:
            clearSplit ? null : (lastSplitResult ?? this.lastSplitResult),
      );
}

class HomeUiNotifier extends StateNotifier<HomeUiState> {
  HomeUiNotifier() : super(const HomeUiState());

  void dismissAlert() => state = state.copyWith(alertsDismissed: true);
  void setPending(bool v) => state = state.copyWith(pendingAction: v);
  void setSplitResult(AutopilotTriggerResponse r) =>
      state = state.copyWith(lastSplitResult: r);
  void clearSplitResult() => state = state.copyWith(clearSplit: true);
}

final homeUiProvider = StateNotifierProvider<HomeUiNotifier, HomeUiState>(
  (_) => HomeUiNotifier(),
);

// ─── Shared name provider ─────────────────────────────────────────────────────

final userNameProvider = FutureProvider<String>((ref) async {
  final userId = ref.watch(resolvedUserIdProvider);
  if (userId == null) return '';
  try {
    final user = await ref.read(repositoryProvider).getUser();
    return user.name;
  } catch (_) {
    return '';
  }
});

// ─── Backward-compat AppState (kept for pockets / squad screens) ──────────────
// These screens have not yet been wired to the repository. They still use
// DemoData via this provider. Will be removed when pockets is integrated.

class AppState {
  const AppState({
    required this.mascotState,
    required this.budget,
    required this.pockets,
    required this.transactions,
    required this.autopilot,
    required this.streakDays,
    required this.alertsDismissed,
  });

  final MascotState mascotState;
  final WeeklyBudget budget;
  final List<PocketModel> pockets;
  final List<TransactionModel> transactions;
  final AutopilotRule autopilot;
  final int streakDays;
  final bool alertsDismissed;

  AppState copyWith({
    MascotState? mascotState,
    WeeklyBudget? budget,
    List<PocketModel>? pockets,
    List<TransactionModel>? transactions,
    AutopilotRule? autopilot,
    int? streakDays,
    bool? alertsDismissed,
  }) =>
      AppState(
        mascotState: mascotState ?? this.mascotState,
        budget: budget ?? this.budget,
        pockets: pockets ?? this.pockets,
        transactions: transactions ?? this.transactions,
        autopilot: autopilot ?? this.autopilot,
        streakDays: streakDays ?? this.streakDays,
        alertsDismissed: alertsDismissed ?? this.alertsDismissed,
      );
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier()
      : super(AppState(
          mascotState: MascotState.alert,
          budget: DemoData.initialBudget,
          pockets: List.of(DemoData.initialPockets),
          transactions: List.of(DemoData.initialTransactions),
          autopilot: DemoData.initialAutopilot,
          streakDays: 8,
          alertsDismissed: false,
        ));

  void addToPocket(String pocketName, double amount) {
    final pockets = state.pockets.map((p) {
      if (p.name == pocketName) return p.copyWith(balance: p.balance + amount);
      return p;
    }).toList();
    state =
        state.copyWith(pockets: pockets, mascotState: MascotState.celebrating);
  }

  void setCelebrating() =>
      state = state.copyWith(mascotState: MascotState.celebrating);
  void setCalm() => state = state.copyWith(mascotState: MascotState.calm);

  void dismissAlert() => state = state.copyWith(alertsDismissed: true);

  void updateAutopilot(AutopilotRule rule) =>
      state = state.copyWith(autopilot: rule);

  // Used by pockets screen for the salary animation undo path.
  void undoSalarySplit() {
    final reverted = state.pockets.map((p) {
      return switch (p.name) {
        'Emergency Fund' =>
          p.copyWith(balance: (p.balance - 240).clamp(0, double.infinity)),
        'PTPTN' =>
          p.copyWith(balance: (p.balance - 120).clamp(0, double.infinity)),
        'Travel' =>
          p.copyWith(balance: (p.balance - 60).clamp(0, double.infinity)),
        _ => p,
      };
    }).toList();
    state = state.copyWith(pockets: reverted);
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (_) => AppStateNotifier(),
);

// ─── Dashboard → WeeklyBudget conversion ──────────────────────────────────────

/// Converts the flat API dashboard response into the WeeklyBudget display model
/// used by WeeklyBudgetCard. Category limits are set to 0 when not provided by
/// the API (the budget screen will show per-category limits via getBudgets).
WeeklyBudget dashboardToWeeklyBudget(DashboardModel d) => WeeklyBudget(
      totalSpent: d.weeklySpendTotal,
      totalBudget: d.weeklyBudgetLimit,
      categories: d.categoryBreakdown
          .map((c) => CategoryBudget(
                category: c.category,
                spent: c.amount,
                limit: 0, // limit unknown from dashboard; 0 = "no limit set"
              ))
          .toList(),
    );

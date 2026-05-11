import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/autopilot_model.dart';
import '../../models/budget.dart';
import '../../models/dashboard_model.dart';
import '../../models/mascot.dart';
import '../../models/transaction_model.dart';
import '../../providers/repository_provider.dart';
import '../../providers/user_id_provider.dart';
import '../pockets/pockets_controller.dart';
import '../squad/squad_controller.dart';
import '../profile/profile_controller.dart';
import '../spend/spend_controller.dart';

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
    debugPrint('[UI] Dashboard refresh requested');
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
    if (state.hasValue) {
      debugPrint(
          '[UI] Dashboard refresh complete. Spend: RM${state.value!.weeklySpendTotal}');
    }
  }

  /// Calls createTransaction, refreshes the dashboard, returns the response.
  /// Returns null on error (caller should show a toast).
  Future<TransactionResponse?> createTransaction({
    required double amount,
    required String merchant,
    required String category,
  }) async {
    final userId = ref.read(resolvedUserIdProvider);
    if (userId == null) return null;

    debugPrint('[API] Calling createTransaction: $merchant, RM$amount');
    ref.read(homeUiProvider.notifier).setPending(true);
    try {
      final result = await ref.read(repositoryProvider).createTransaction(
            TransactionCreateRequest(
              amount: amount,
              merchant: merchant,
              category: category,
              userId: userId,
            ),
          );
      debugPrint('[API] Transaction created: ID=${result.transaction.id}');

      // If it was a savings transaction, show celebrating mascot
      if (category.toUpperCase() == 'SAVINGS') {
        ref.read(homeUiProvider.notifier).setMascotOverride(result.mascot);
      }

      // Refresh everything
      debugPrint('[UI] Refreshing all providers...');
      ref.invalidate(transactionsProvider);
      ref.invalidate(spendInsightProvider);
      ref.invalidate(pocketsAsyncProvider);
      ref.invalidate(profileProvider);
      ref.invalidate(squadNotifierProvider);

      // Refresh dashboard and wait for it
      state = const AsyncLoading();
      state = await AsyncValue.guard(_load);

      if (state.hasValue) {
        debugPrint(
            '[UI] State update confirmed. New total: RM${state.value!.weeklySpendTotal}');
      }

      return result;
    } catch (e) {
      debugPrint('[API] Error creating transaction: $e');
      return null;
    } finally {
      ref.read(homeUiProvider.notifier).setPending(false);
    }
  }

  /// Creates a salary transaction then triggers autopilot.
  /// Returns the split result (or null on failure).
  Future<AutopilotTriggerResponse?> receiveSalary(
      {required double salaryAmount}) async {
    final userId = ref.read(resolvedUserIdProvider);
    if (userId == null) return null;

    debugPrint('[API] Calling receiveSalary: RM$salaryAmount');
    ref.read(homeUiProvider.notifier).setPending(true);
    try {
      final txResult = await ref.read(repositoryProvider).createTransaction(
            TransactionCreateRequest(
              amount: salaryAmount,
              merchant: 'Salary Credit',
              category: 'SALARY',
              userId: userId,
            ),
          );
      debugPrint('[API] Salary transaction created. Triggering autopilot...');

      final splitResult = await ref.read(repositoryProvider).triggerAutopilot(
            transactionId: txResult.transaction.id,
            userId: userId,
          );
      debugPrint(
          '[API] Autopilot complete. Routed RM${splitResult.totalRouted}');

      // Autopilot always triggers celebrating
      if (splitResult.mascot != null) {
        ref
            .read(homeUiProvider.notifier)
            .setMascotOverride(splitResult.mascot!);
      }

      // Refresh everything
      debugPrint('[UI] Refreshing all providers...');
      ref.invalidate(transactionsProvider);
      ref.invalidate(spendInsightProvider);
      ref.invalidate(pocketsAsyncProvider);
      ref.invalidate(profileProvider);
      ref.invalidate(squadNotifierProvider);

      state = const AsyncLoading();
      state = await AsyncValue.guard(_load);

      return splitResult;
    } catch (e) {
      debugPrint('[API] Error receiving salary: $e');
      return null;
    } finally {
      ref.read(homeUiProvider.notifier).setPending(false);
    }
  }

  Future<bool> undoAutopilot(String splitId) async {
    final userId = ref.read(resolvedUserIdProvider);
    debugPrint('[API] Undoing autopilot: $splitId');
    ref.read(homeUiProvider.notifier).setPending(true);
    try {
      final result = await ref.read(repositoryProvider).undoAutopilot(
            splitId: splitId,
            userId: userId,
          );
      if (result.reversed) {
        debugPrint('[API] Undo successful. Refreshing state...');
        ref.invalidate(transactionsProvider);
        ref.invalidate(spendInsightProvider);
        ref.invalidate(pocketsAsyncProvider);
        ref.invalidate(profileProvider);
        ref.invalidate(squadNotifierProvider);

        state = const AsyncLoading();
        state = await AsyncValue.guard(_load);
      }
      return result.reversed;
    } catch (e) {
      debugPrint('[API] Error undoing autopilot: $e');
      return false;
    } finally {
      ref.read(homeUiProvider.notifier).setPending(false);
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
    this.mascotOverride,
  });

  final bool alertsDismissed;
  final bool pendingAction;
  final AutopilotTriggerResponse? lastSplitResult;
  final MascotModel? mascotOverride;

  HomeUiState copyWith({
    bool? alertsDismissed,
    bool? pendingAction,
    AutopilotTriggerResponse? lastSplitResult,
    MascotModel? mascotOverride,
    bool clearSplit = false,
    bool clearMascot = false,
  }) =>
      HomeUiState(
        alertsDismissed: alertsDismissed ?? this.alertsDismissed,
        pendingAction: pendingAction ?? this.pendingAction,
        lastSplitResult:
            clearSplit ? null : (lastSplitResult ?? this.lastSplitResult),
        mascotOverride:
            clearMascot ? null : (mascotOverride ?? this.mascotOverride),
      );
}

class HomeUiNotifier extends StateNotifier<HomeUiState> {
  HomeUiNotifier() : super(const HomeUiState());

  void dismissAlert() => state = state.copyWith(alertsDismissed: true);
  void setPending(bool v) => state = state.copyWith(pendingAction: v);
  void setSplitResult(AutopilotTriggerResponse r) =>
      state = state.copyWith(lastSplitResult: r);
  void clearSplitResult() => state = state.copyWith(clearSplit: true);

  void setMascotOverride(MascotModel m) {
    state = state.copyWith(mascotOverride: m);
    // Clear after 5 seconds to return to baseline
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) clearMascotOverride();
    });
  }

  void clearMascotOverride() => state = state.copyWith(clearMascot: true);
}

final homeUiProvider = StateNotifierProvider<HomeUiNotifier, HomeUiState>(
  (_) => HomeUiNotifier(),
);

// ─── Shared name provider ─────────────────────────────────────────────────────

final userNameProvider = FutureProvider<String>((ref) async {
  final userId = ref.watch(resolvedUserIdProvider);
  if (userId == null) return '';
  try {
    final user = await ref.read(repositoryProvider).getUserProfile(userId: userId);
    return user.shortName;
  } catch (_) {
    return '';
  }
});

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

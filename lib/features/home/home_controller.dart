import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/budget.dart';
import '../../models/mascot.dart';
import '../../models/pocket.dart';
import '../../models/transaction.dart';
import '../../models/autopilot_rule.dart';
import '../../shared/constants/demo_data.dart';

// ─── App-wide shared state ────────────────────────────────────────────────────

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

  MascotState _deriveMascotState(WeeklyBudget b) {
    final pct = b.overallPercent;
    if (pct >= 1.0) return MascotState.panicked;
    if (pct >= 0.6) return MascotState.alert;
    return MascotState.calm;
  }

  void spendFood(double amount) {
    final food = state.budget.category('food')!;
    final updated = food.copyWith(spent: food.spent + amount);
    final newBudget = _replaceCategory(state.budget, updated);
    final newTx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      name: 'GrabFood',
      amount: amount,
      category: 'Food',
      riskLabel: 'Risky',
      timestamp: DateTime.now(),
      glyph: '🍔',
      colorHex: '#10B981',
    );
    state = state.copyWith(
      budget: newBudget,
      transactions: [newTx, ...state.transactions],
      mascotState: _deriveMascotState(newBudget),
    );
  }

  void spendShopping(double amount) {
    final shopping = state.budget.category('shopping')!;
    final updated = shopping.copyWith(spent: shopping.spent + amount);
    final newBudget = _replaceCategory(state.budget, updated);
    final newTx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Shopee',
      amount: amount,
      category: 'Shopping',
      riskLabel: 'Risky',
      timestamp: DateTime.now(),
      glyph: 'S',
      colorHex: '#F8326D',
    );
    state = state.copyWith(
      budget: newBudget,
      transactions: [newTx, ...state.transactions],
      mascotState: MascotState.panicked,
    );
  }

  void addToPocket(String pocketName, double amount) {
    final pockets = state.pockets.map((p) {
      if (p.name == pocketName) return p.copyWith(balance: p.balance + amount);
      return p;
    }).toList();
    state = state.copyWith(pockets: pockets, mascotState: MascotState.celebrating);
  }

  void receiveSalary() {
    final salaryTx = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Salary Credit',
      amount: DemoData.salaryAmount,
      category: 'Income',
      riskLabel: 'Income',
      timestamp: DateTime.now(),
      glyph: '💸',
      colorHex: '#7C3AED',
      isIncome: true,
    );
    final newPockets = state.pockets.map((p) {
      return switch (p.name) {
        'Emergency Fund' => p.copyWith(balance: p.balance + 240),
        'PTPTN' => p.copyWith(balance: p.balance + 120),
        'Travel' => p.copyWith(balance: p.balance + 60),
        _ => p,
      };
    }).toList();
    state = state.copyWith(
      pockets: newPockets,
      transactions: [salaryTx, ...state.transactions],
      mascotState: MascotState.celebrating,
      autopilot: state.autopilot.copyWith(lastSplitAmount: DemoData.totalSalarySplit),
    );
  }

  void undoSalarySplit() {
    final revertedPockets = state.pockets.map((p) {
      return switch (p.name) {
        'Emergency Fund' => p.copyWith(balance: (p.balance - 240).clamp(0, double.infinity)),
        'PTPTN' => p.copyWith(balance: (p.balance - 120).clamp(0, double.infinity)),
        'Travel' => p.copyWith(balance: (p.balance - 60).clamp(0, double.infinity)),
        _ => p,
      };
    }).toList();
    state = state.copyWith(pockets: revertedPockets);
  }

  void setCelebrating() => state = state.copyWith(mascotState: MascotState.celebrating);
  void setCalm() => state = state.copyWith(mascotState: MascotState.calm);

  void dismissAlert() => state = state.copyWith(alertsDismissed: true);

  void updateAutopilot(AutopilotRule rule) => state = state.copyWith(autopilot: rule);

  WeeklyBudget _replaceCategory(WeeklyBudget budget, CategoryBudget updated) {
    final cats = budget.categories.map((c) {
      return c.category == updated.category ? updated : c;
    }).toList();
    final newTotal = cats.fold(0.0, (s, c) => s + c.spent);
    return budget.copyWith(totalSpent: newTotal, categories: cats);
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (_) => AppStateNotifier(),
);

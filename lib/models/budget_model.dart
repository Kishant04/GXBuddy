/// A single budget progress line from GET /budgets.
/// Matches BudgetProgress from the backend.
/// category == null (or 'overall') means the overall weekly budget.
class BudgetModel {
  const BudgetModel({
    required this.budgetId,
    this.category,
    required this.weeklyLimit,
    required this.spentAmount,
    required this.usagePercent,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) => BudgetModel(
        budgetId: json['budget_id'] as String? ?? '',
        category: json['category'] as String?,
        weeklyLimit: _toDouble(json['weekly_limit']),
        spentAmount: _toDouble(json['spent_amount']),
        usagePercent: (json['usage_percent'] as num?)?.toDouble() ?? 0,
      );

  final String budgetId;
  final String? category;
  final double weeklyLimit;
  final double spentAmount;
  final double usagePercent;

  bool get isOverall =>
      category == null || category!.toLowerCase() == 'overall';
  bool get isOverBudget => usagePercent > 100;
}

/// Category spend item from the dashboard `category_breakdown` list.
class CategorySpendModel {
  const CategorySpendModel({required this.category, required this.amount});

  factory CategorySpendModel.fromJson(Map<String, dynamic> json) =>
      CategorySpendModel(
        category: json['category'] as String? ?? '',
        amount: _toDouble(json['amount']),
      );

  final String category;
  final double amount;
}

/// Streak information from the dashboard `streak_summary` object.
class StreakSummaryModel {
  const StreakSummaryModel({
    required this.currentStreak,
    required this.bestStreak,
    this.lastSaveDate,
  });

  factory StreakSummaryModel.fromJson(Map<String, dynamic> json) =>
      StreakSummaryModel(
        currentStreak: json['current_streak'] as int? ?? 0,
        bestStreak: json['best_streak'] as int? ?? 0,
        lastSaveDate: json['last_save_date'] != null
            ? DateTime.tryParse(json['last_save_date'] as String)
            : null,
      );

  static const StreakSummaryModel empty = StreakSummaryModel(
    currentStreak: 0,
    bestStreak: 0,
  );

  final int currentStreak;
  final int bestStreak;
  final DateTime? lastSaveDate;
}

/// Pocket summary card from the dashboard `pocket_summaries` list.
class PocketSummaryModel {
  const PocketSummaryModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.target,
    required this.progressPercent,
  });

  factory PocketSummaryModel.fromJson(Map<String, dynamic> json) =>
      PocketSummaryModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        balance: _toDouble(json['balance']),
        target: _toDouble(json['target']),
        progressPercent: (json['progress_percent'] as num?)?.toDouble() ?? 0,
      );

  final String id;
  final String name;
  final double balance;
  final double target;
  final double progressPercent;
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

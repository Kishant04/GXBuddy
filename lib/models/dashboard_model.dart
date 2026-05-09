import 'mascot_model.dart';
import 'alert_model.dart';
import 'bill_model.dart';
import 'budget_model.dart';
import 'transaction_model.dart';

/// Full dashboard response from GET /api/dashboard.
/// Matches the backend DashboardResponse schema.
class DashboardModel {
  const DashboardModel({
    required this.mascot,
    required this.weeklySpendTotal,
    required this.weeklyBudgetLimit,
    required this.weeklyBudgetUsedPercent,
    required this.categoryBreakdown,
    required this.upcomingBills,
    required this.recentAlerts,
    required this.pocketSummaries,
    required this.streakSummary,
    required this.recentTransactions,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        mascot: json['mascot'] != null
            ? MascotModel.fromJson(json['mascot'] as Map<String, dynamic>)
            : const MascotModel(state: MascotState.calm, moodLine: ''),
        weeklySpendTotal: _toDouble(json['weekly_spend_total']),
        weeklyBudgetLimit: _toDouble(json['weekly_budget_limit']),
        weeklyBudgetUsedPercent:
            (json['weekly_budget_used_percent'] as num?)?.toDouble() ?? 0,
        categoryBreakdown: (json['category_breakdown'] as List<dynamic>? ?? [])
            .map((e) => CategorySpendModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        upcomingBills: (json['upcoming_bills'] as List<dynamic>? ?? [])
            .map((e) => BillModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        recentAlerts: (json['recent_alerts'] as List<dynamic>? ?? [])
            .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        pocketSummaries: (json['pocket_summaries'] as List<dynamic>? ?? [])
            .map((e) => PocketSummaryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        streakSummary: json['streak_summary'] != null
            ? StreakSummaryModel.fromJson(
                json['streak_summary'] as Map<String, dynamic>)
            : StreakSummaryModel.empty,
        recentTransactions: (json['recent_transactions'] as List<dynamic>? ??
                [])
            .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final MascotModel mascot;
  final double weeklySpendTotal;
  final double weeklyBudgetLimit;
  final double weeklyBudgetUsedPercent;
  final List<CategorySpendModel> categoryBreakdown;
  final List<BillModel> upcomingBills;
  final List<AlertModel> recentAlerts;
  final List<PocketSummaryModel> pocketSummaries;
  final StreakSummaryModel streakSummary;
  final List<TransactionModel> recentTransactions;
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

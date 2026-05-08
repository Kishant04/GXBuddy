import 'mascot.dart';
import 'budget.dart';
import 'pocket.dart';
import 'alert.dart';
import 'bill_reminder.dart';

class DashboardResponse {
  const DashboardResponse({
    required this.mascot,
    required this.weeklyBudget,
    required this.pockets,
    required this.activeAlerts,
    required this.upcomingBills,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) => DashboardResponse(
        mascot: MascotModel.fromJson(json['mascot'] as Map<String, dynamic>),
        weeklyBudget: WeeklyBudget.fromJson(json['weekly_spend'] as Map<String, dynamic>),
        pockets: (json['pockets'] as List<dynamic>? ?? [])
            .map((p) => PocketModel.fromJson(p as Map<String, dynamic>))
            .toList(),
        activeAlerts: (json['active_alerts'] as List<dynamic>? ?? [])
            .map((a) => AlertModel.fromJson(a as Map<String, dynamic>))
            .toList(),
        upcomingBills: (json['upcoming_bills'] as List<dynamic>? ?? [])
            .map((b) => BillReminder.fromJson(b as Map<String, dynamic>))
            .toList(),
      );

  final MascotModel mascot;
  final WeeklyBudget weeklyBudget;
  final List<PocketModel> pockets;
  final List<AlertModel> activeAlerts;
  final List<BillReminder> upcomingBills;
}

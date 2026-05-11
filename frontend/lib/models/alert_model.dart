// Backend severity values: calm | alert | panicked | celebrating | emergency
// Frontend enum maps these to display tiers.
enum AlertSeverity { info, alert, warning, danger }

class AlertModel {
  const AlertModel({
    required this.id,
    required this.message,
    required this.severity,
    this.userId,
    this.actionTaken = false,
    this.createdAt,
    // UI-only action fields (set by application logic, not from backend)
    this.actionLabel,
    this.actionAmount,
    this.targetPocket,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        id: json['id'] as String? ?? '',
        userId: json['user_id'] as String?,
        message: json['message'] as String? ?? '',
        severity:
            AlertModel.severityFromString(json['severity'] as String? ?? ''),
        actionTaken: json['action_taken'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        // Backend does not return action_label / action_amount / target_pocket.
        // These are left null when parsing from API response.
        actionLabel: json['action_label'] as String?,
        actionAmount: (json['action_amount'] as num?)?.toDouble(),
        targetPocket: json['target_pocket'] as String?,
      );

  static AlertSeverity severityFromString(String s) =>
      switch (s.toLowerCase()) {
        'danger' || 'panicked' || 'emergency' => AlertSeverity.danger,
        'warning' => AlertSeverity.warning,
        'alert' => AlertSeverity.alert,
        _ => AlertSeverity.info,
      };

  final String id;
  final String? userId;
  final String message;
  final AlertSeverity severity;
  final bool actionTaken;
  final DateTime? createdAt;
  final String? actionLabel;
  final double? actionAmount;
  final String? targetPocket;
}

enum AlertSeverity { info, alert, warning, danger }

class AlertModel {
  const AlertModel({
    required this.id,
    required this.message,
    required this.severity,
    this.actionLabel,
    this.actionAmount,
    this.targetPocket,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        id: json['id'] as String? ?? '',
        message: json['message'] as String,
        severity: _severityFromString(json['severity'] as String? ?? 'info'),
        actionLabel: json['action_label'] as String?,
        actionAmount: (json['action_amount'] as num?)?.toDouble(),
        targetPocket: json['target_pocket'] as String?,
      );

  static AlertSeverity _severityFromString(String s) => switch (s) {
        'danger' => AlertSeverity.danger,
        'warning' => AlertSeverity.warning,
        'alert' => AlertSeverity.alert,
        _ => AlertSeverity.info,
      };

  final String id;
  final String message;
  final AlertSeverity severity;
  final String? actionLabel;
  final double? actionAmount;
  final String? targetPocket;
}

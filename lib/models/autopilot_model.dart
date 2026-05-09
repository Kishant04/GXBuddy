/// One line item in the autopilot salary split result.
class SplitLine {
  const SplitLine({
    required this.pocketId,
    required this.pocketName,
    required this.amount,
    required this.ruleType,
    required this.ruleValue,
  });

  factory SplitLine.fromJson(Map<String, dynamic> json) => SplitLine(
        pocketId: json['pocket_id'] as String? ?? '',
        pocketName: json['pocket_name'] as String? ?? '',
        amount: _toDouble(json['amount']),
        ruleType: json['rule_type'] as String? ?? 'percent',
        ruleValue: _toDouble(json['rule_value']),
      );

  final String pocketId;
  final String pocketName;
  final double amount;
  final String ruleType; // 'percent' | 'fixed'
  final double ruleValue;
}

/// Response from POST /api/autopilot/trigger.
class AutopilotTriggerResponse {
  const AutopilotTriggerResponse({
    required this.splitId,
    required this.totalRouted,
    required this.lines,
    this.undoDeadline,
  });

  factory AutopilotTriggerResponse.fromJson(Map<String, dynamic> json) =>
      AutopilotTriggerResponse(
        splitId: json['split_id'] as String? ?? '',
        totalRouted: _toDouble(json['total_routed']),
        lines: (json['lines'] as List<dynamic>? ?? [])
            .map((e) => SplitLine.fromJson(e as Map<String, dynamic>))
            .toList(),
        undoDeadline: json['undo_deadline'] != null
            ? DateTime.tryParse(json['undo_deadline'] as String)
            : null,
      );

  final String splitId;
  final double totalRouted;
  final List<SplitLine> lines;
  final DateTime? undoDeadline;

  bool get canUndo {
    final deadline = undoDeadline;
    if (deadline == null) return false;
    return DateTime.now().isBefore(deadline);
  }
}

/// Response from POST /api/autopilot/undo.
class AutopilotUndoResponse {
  const AutopilotUndoResponse({required this.reversed, required this.message});

  factory AutopilotUndoResponse.fromJson(Map<String, dynamic> json) =>
      AutopilotUndoResponse(
        reversed: json['reversed'] as bool? ?? false,
        message: json['message'] as String? ?? '',
      );

  final bool reversed;
  final String message;
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

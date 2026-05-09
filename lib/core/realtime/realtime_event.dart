import 'dart:convert';

enum RealtimeEventType {
  alert,
  mascotState,
  billWarning,
  transactionProcessed,
  streakShield,
  rally,
  unknown,
}

class RealtimeEvent {
  const RealtimeEvent({required this.type, required this.data});

  factory RealtimeEvent.fromJson(Map<String, dynamic> json) {
    final type = switch (json['type'] as String?) {
      'alert' => RealtimeEventType.alert,
      'mascot_state' => RealtimeEventType.mascotState,
      'bill_warning' => RealtimeEventType.billWarning,
      'transaction_processed' => RealtimeEventType.transactionProcessed,
      'streak_shield' => RealtimeEventType.streakShield,
      'rally' => RealtimeEventType.rally,
      _ => RealtimeEventType.unknown,
    };
    return RealtimeEvent(
      type: type,
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  factory RealtimeEvent.fromRaw(String raw) =>
      RealtimeEvent.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  final RealtimeEventType type;
  final Map<String, dynamic> data;

  // ── Shared accessors ──────────────────────────────────────
  String? get message => data['message'] as String?;
  String? get severity => data['severity'] as String?;

  // ── Mascot ────────────────────────────────────────────────
  String? get mascotStateStr => data['state'] as String?;
  String? get moodLine => data['mood_line'] as String?;

  // ── Bill warning ──────────────────────────────────────────
  String? get billId => data['bill_id'] as String?;
  String? get billName => data['name'] as String?;
  int? get daysRemaining => data['days_remaining'] as int?;

  // ── Transaction processed ─────────────────────────────────
  String? get transactionId => data['transaction_id'] as String?;
  double? get riskScore => (data['risk_score'] as num?)?.toDouble();

  // ── Squad ─────────────────────────────────────────────────
  int? get memberIndex => data['member_index'] as int?;
  String? get squadId => data['squad_id'] as String?;
}

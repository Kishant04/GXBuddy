import 'dart:convert';

enum RealtimeEventType {
  alert,
  mascotState,
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
      'streak_shield' => RealtimeEventType.streakShield,
      'rally' => RealtimeEventType.rally,
      _ => RealtimeEventType.unknown,
    };
    return RealtimeEvent(type: type, data: json['data'] as Map<String, dynamic>? ?? {});
  }

  factory RealtimeEvent.fromRaw(String raw) =>
      RealtimeEvent.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  final RealtimeEventType type;
  final Map<String, dynamic> data;

  String? get message => data['message'] as String?;
  String? get severity => data['severity'] as String?;
  String? get mascotStateStr => data['state'] as String?;
  String? get moodLine => data['mood_line'] as String?;
  int? get memberIndex => data['member_index'] as int?;
  String? get squadId => data['squad_id'] as String?;
}

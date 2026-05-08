import 'package:flutter/material.dart';

class SquadMember {
  const SquadMember({
    required this.id,
    required this.displayName,
    required this.initials,
    required this.progressPercent,
    required this.streakDays,
    required this.colorHex,
    required this.status,
    this.isYou = false,
  });

  factory SquadMember.fromJson(Map<String, dynamic> json) => SquadMember(
        id: json['id'] as String? ?? '',
        displayName: json['name'] as String,
        initials: json['initials'] as String? ?? 'X',
        progressPercent: (json['progress'] as num).toDouble(),
        streakDays: json['streak'] as int? ?? 0,
        colorHex: json['color'] as String? ?? '#771FFF',
        status: json['status'] as String? ?? 'On track',
        isYou: json['you'] as bool? ?? false,
      );

  final String id;
  final String displayName;
  final String initials;
  final double progressPercent;
  final int streakDays;
  final String colorHex;
  final String status;
  final bool isYou;

  bool get needsNudge => status == 'Needs nudge';

  Color get color {
    final hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

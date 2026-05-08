import 'squad_member.dart';

class SquadModel {
  const SquadModel({
    required this.id,
    required this.name,
    required this.goalDescription,
    required this.goalAmount,
    required this.progressPercent,
    required this.daysLeft,
    required this.members,
    required this.weeklyInsight,
    required this.rewardDescription,
  });

  factory SquadModel.fromJson(Map<String, dynamic> json) => SquadModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String,
        goalDescription: json['goal_description'] as String? ?? '',
        goalAmount: (json['goal_amount'] as num?)?.toDouble() ?? 500,
        progressPercent: (json['progress'] as num).toDouble(),
        daysLeft: json['days_left'] as int? ?? 0,
        members: (json['members'] as List<dynamic>? ?? [])
            .map((m) => SquadMember.fromJson(m as Map<String, dynamic>))
            .toList(),
        weeklyInsight: json['weekly_insight'] as String? ?? '',
        rewardDescription: json['reward_description'] as String? ?? '',
      );

  final String id;
  final String name;
  final String goalDescription;
  final double goalAmount;
  final double progressPercent;
  final int daysLeft;
  final List<SquadMember> members;
  final String weeklyInsight;
  final String rewardDescription;

  double get savedAmount => goalAmount * progressPercent / 100;
}

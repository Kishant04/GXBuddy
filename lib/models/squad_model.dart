import 'package:flutter/material.dart';

// ── Request types ─────────────────────────────────────────────────────────────

class SquadCreate {
  const SquadCreate({
    required this.name,
    required this.goalName,
    required this.goalAmount,
    required this.deadline,
    this.privacyMode = 'ANONYMOUS',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'goal_name': goalName,
        'goal_amount': goalAmount,
        'deadline': deadline.toIso8601String(),
        'privacy_mode': privacyMode,
      };

  final String name;
  final String goalName;
  final double goalAmount;
  final DateTime deadline;
  final String privacyMode;
}

// ── Backend member (anonymous) ─────────────────────────────────────────────────

/// Raw member shape from the backend. Squad members are anonymous by design.
class MemberView {
  const MemberView({
    required this.memberIndex,
    required this.progressScore,
    required this.streakDays,
    required this.goalStatus,
    required this.isSelf,
  });

  factory MemberView.fromJson(Map<String, dynamic> json) => MemberView(
        memberIndex: json['member_index'] as int? ?? 0,
        progressScore: (json['progress_score'] as num?)?.toDouble() ?? 0,
        streakDays: json['streak_days'] as int? ?? 0,
        goalStatus: json['goal_status'] as String? ?? 'On track',
        isSelf: json['is_self'] as bool? ?? false,
      );

  final int memberIndex;
  final double progressScore;
  final int streakDays;
  final String goalStatus;
  final bool isSelf;

  /// Converts an anonymous MemberView to the display model used by the UI.
  SquadMember toSquadMember() => SquadMember(
        id: 'm$memberIndex',
        displayName: isSelf ? 'You' : 'Member $memberIndex',
        initials: isSelf ? 'Y' : 'M$memberIndex',
        progressPercent: progressScore,
        streakDays: streakDays,
        colorHex: _colorForIndex(memberIndex),
        status: goalStatus,
        isYou: isSelf,
      );

  static const _palette = [
    '#A855F7',
    '#1FB287',
    '#F8326D',
    '#3B82F6',
    '#F59E0B',
    '#06B6D4',
    '#22C55E',
    '#8B5CF6',
  ];

  static String _colorForIndex(int index) =>
      _palette[index.abs() % _palette.length];
}

// ── AI insight ────────────────────────────────────────────────────────────────

class SquadInsight {
  const SquadInsight({
    required this.paragraph,
    required this.nudgeTargets,
    required this.collectiveAction,
  });

  factory SquadInsight.fromJson(Map<String, dynamic> json) => SquadInsight(
        paragraph: json['paragraph'] as String? ?? '',
        nudgeTargets: (json['nudge_targets'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        collectiveAction: json['collective_action'] as String? ?? '',
      );

  final String paragraph;
  final List<String> nudgeTargets;
  final String collectiveAction;
}

// ── Display member (used by UI) ───────────────────────────────────────────────

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
        displayName:
            json['name'] as String? ?? json['display_name'] as String? ?? '',
        initials: json['initials'] as String? ?? 'X',
        progressPercent: (json['progress'] as num?)?.toDouble() ??
            (json['progress_percent'] as num?)?.toDouble() ??
            0,
        streakDays: json['streak'] as int? ?? json['streak_days'] as int? ?? 0,
        colorHex: json['color'] as String? ??
            json['color_hex'] as String? ??
            '#771FFF',
        status: json['status'] as String? ?? 'On track',
        isYou: json['you'] as bool? ?? json['is_you'] as bool? ?? false,
      );

  final String id;
  final String displayName;
  final String initials;
  final double progressPercent;
  final int streakDays;
  final String colorHex;
  final String status;
  final bool isYou;

  bool get needsNudge => status.toLowerCase().contains('nudge');

  /// Extracts the 1-based member index used by sendRally.
  /// IDs created from MemberView use the pattern 'm$memberIndex'.
  int? get parsedMemberIndex {
    if (id.startsWith('m')) return int.tryParse(id.substring(1));
    return int.tryParse(id);
  }

  Color get color {
    final hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

// ── Squad model ───────────────────────────────────────────────────────────────

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
    this.inviteCode,
    this.privacyMode,
    this.deadline,
  });

  factory SquadModel.fromJson(Map<String, dynamic> json) {
    // Support both snake_case and camelCase variants.
    final id = _str(json['squad_id'] ?? json['squadid'] ?? json['id']);
    final goalDescription =
        _str(json['goal_name'] ?? json['goalname'] ?? json['goal_description']);
    final inviteCode = _strN(json['invite_code'] ?? json['invitecode']);
    final goalAmount = _toDouble(json['goal_amount'] ?? json['goalamount']);
    final deadline = json['deadline'] != null
        ? DateTime.tryParse(json['deadline'] as String)
        : null;

    // Members: parse as anonymous MemberView, convert to display SquadMember.
    final rawMembers = json['members'] as List<dynamic>? ?? [];
    List<SquadMember> members;
    if (rawMembers.isNotEmpty) {
      final first = rawMembers.first as Map<String, dynamic>;
      // Detect backend anonymous format by presence of member_index.
      if (first.containsKey('member_index')) {
        members = rawMembers
            .map((e) =>
                MemberView.fromJson(e as Map<String, dynamic>).toSquadMember())
            .toList();
      } else {
        members = rawMembers
            .map((e) => SquadMember.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } else {
      members = [];
    }

    // Progress: may come directly or be computed from members.
    double progress = _toDouble(json['progress']);
    if (progress == 0 && members.isNotEmpty) {
      progress =
          members.fold(0.0, (s, m) => s + m.progressPercent) / members.length;
    }

    // Days left: compute from deadline if not provided.
    int daysLeft = json['days_left'] as int? ?? json['daysleft'] as int? ?? 0;
    if (daysLeft == 0 && deadline != null) {
      daysLeft = deadline.difference(DateTime.now()).inDays.clamp(0, 9999);
    }

    // Weekly insight: from ai_insight object or direct field.
    String weeklyInsight = '';
    final insight = json['insight'] ?? json['ai_insight'];
    if (insight is Map<String, dynamic>) {
      weeklyInsight = insight['paragraph'] as String? ?? '';
    } else if (insight is String) {
      weeklyInsight = insight;
    }
    weeklyInsight = weeklyInsight.isEmpty
        ? json['weekly_insight'] as String? ?? ''
        : weeklyInsight;

    return SquadModel(
      id: id,
      name: json['name'] as String? ?? '',
      goalDescription: goalDescription,
      goalAmount: goalAmount,
      progressPercent: progress,
      daysLeft: daysLeft,
      members: members,
      weeklyInsight: weeklyInsight,
      rewardDescription: json['reward_description'] as String? ??
          json['rewarddescription'] as String? ??
          '',
      inviteCode: inviteCode,
      privacyMode: json['privacy_mode'] as String?,
      deadline: deadline,
    );
  }

  final String id;
  final String name;
  final String goalDescription;
  final double goalAmount;
  final double progressPercent;
  final int daysLeft;
  final List<SquadMember> members;
  final String weeklyInsight;
  final String rewardDescription;
  final String? inviteCode;
  final String? privacyMode;
  final DateTime? deadline;

  double get savedAmount => goalAmount * progressPercent / 100;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _str(dynamic v) => v as String? ?? '';
String? _strN(dynamic v) => v as String?;

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

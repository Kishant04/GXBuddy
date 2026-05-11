import 'package:flutter/material.dart';

/// Backend split rule for a pocket (percent or fixed RM amount).
class SplitRule {
  const SplitRule({required this.type, required this.value});

  factory SplitRule.fromJson(Map<String, dynamic> json) => SplitRule(
        type: json['type'] as String? ?? 'percent',
        value: _toDouble(json['value']),
      );

  Map<String, dynamic> toJson() => {'type': type, 'value': value};

  final String type; // 'percent' | 'fixed'
  final double value;

  bool get isPercent => type == 'percent';
}

/// Request body for POST /api/pockets/ and PATCH /api/pockets/{id}.
class PocketCreate {
  const PocketCreate({
    required this.name,
    required this.target,
    required this.splitRule,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'target': target,
        'split_rule': splitRule.toJson(),
      };

  final String name;
  final double target;
  final SplitRule splitRule;
}

class PocketModel {
  const PocketModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.target,
    required this.colorHex,
    required this.icon,
    required this.note,
    required this.eta,
    this.splitRule,
    this.percentComplete,
  });

  factory PocketModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final splitRule = json['split_rule'] != null
        ? SplitRule.fromJson(json['split_rule'] as Map<String, dynamic>)
        : null;
    final note = PocketModel.buildNote(splitRule);
    return PocketModel(
      id: id,
      name: json['name'] as String? ?? '',
      balance: _toDouble(json['balance']),
      target: _toDouble(json['target']),
      // Color and icon are UI-only — derive a stable value from the id hash.
      colorHex: json['color'] as String? ?? _colorForId(id),
      icon: json['icon'] as String? ?? '💰',
      note: json['note'] as String? ?? note,
      eta: json['eta'] as String? ?? '',
      splitRule: splitRule,
      percentComplete: (json['percent_complete'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String name;
  final double balance;
  final double target;
  final String colorHex;
  final String icon;
  final String note;
  final String eta;
  final SplitRule? splitRule;
  final double? percentComplete;

  double get percent => target > 0 ? (balance / target).clamp(0.0, 1.0) : 0.0;
  int get percentInt => (percent * 100).round();

  Color get color {
    final hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  PocketModel copyWith({
    String? id,
    String? name,
    double? balance,
    double? target,
    String? colorHex,
    String? icon,
    String? note,
    String? eta,
    SplitRule? splitRule,
    double? percentComplete,
  }) =>
      PocketModel(
        id: id ?? this.id,
        name: name ?? this.name,
        balance: balance ?? this.balance,
        target: target ?? this.target,
        colorHex: colorHex ?? this.colorHex,
        icon: icon ?? this.icon,
        note: note ?? this.note,
        eta: eta ?? this.eta,
        splitRule: splitRule ?? this.splitRule,
        percentComplete: percentComplete ?? this.percentComplete,
      );

  static String _colorForId(String id) {
    const palette = [
      '#1FB287',
      '#3B82F6',
      '#F8326D',
      '#A855F7',
      '#F59E0B',
      '#06B6D4',
    ];
    if (id.isEmpty) return palette[0];
    return palette[id.hashCode.abs() % palette.length];
  }

  static String buildNote(SplitRule? rule) {
    if (rule == null) return '';
    return rule.isPercent
        ? 'Auto · ${rule.value.toStringAsFixed(0)}% of salary'
        : 'Auto · RM${rule.value.toStringAsFixed(0)} fixed';
  }
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

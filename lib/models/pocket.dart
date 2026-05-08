import 'package:flutter/material.dart';

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
  });

  factory PocketModel.fromJson(Map<String, dynamic> json) => PocketModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String,
        balance: (json['balance'] as num).toDouble(),
        target: (json['target'] as num).toDouble(),
        colorHex: json['color'] as String? ?? '#771FFF',
        icon: json['icon'] as String? ?? '💰',
        note: json['note'] as String? ?? '',
        eta: json['eta'] as String? ?? '',
      );

  final String id;
  final String name;
  final double balance;
  final double target;
  final String colorHex;
  final String icon;
  final String note;
  final String eta;

  double get percent => target > 0 ? (balance / target).clamp(0.0, 1.0) : 0.0;
  int get percentInt => (percent * 100).round();

  Color get color {
    final hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  PocketModel copyWith({String? id, String? name, double? balance, double? target,
      String? colorHex, String? icon, String? note, String? eta}) =>
      PocketModel(
        id: id ?? this.id,
        name: name ?? this.name,
        balance: balance ?? this.balance,
        target: target ?? this.target,
        colorHex: colorHex ?? this.colorHex,
        icon: icon ?? this.icon,
        note: note ?? this.note,
        eta: eta ?? this.eta,
      );
}

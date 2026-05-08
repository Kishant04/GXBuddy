class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.riskLabel,
    required this.timestamp,
    required this.glyph,
    required this.colorHex,
    this.isIncome = false,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        riskLabel: json['risk'] as String? ?? 'Safe',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        glyph: json['glyph'] as String? ?? '?',
        colorHex: json['color'] as String? ?? '#771FFF',
        isIncome: json['income'] as bool? ?? false,
      );

  final String id;
  final String name;
  final double amount;
  final String category;
  final String riskLabel;
  final DateTime timestamp;
  final String glyph;
  final String colorHex;
  final bool isIncome;

  TransactionModel copyWith({String? id, String? name, double? amount, String? category,
      String? riskLabel, DateTime? timestamp, String? glyph, String? colorHex, bool? isIncome}) =>
      TransactionModel(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        riskLabel: riskLabel ?? this.riskLabel,
        timestamp: timestamp ?? this.timestamp,
        glyph: glyph ?? this.glyph,
        colorHex: colorHex ?? this.colorHex,
        isIncome: isIncome ?? this.isIncome,
      );
}

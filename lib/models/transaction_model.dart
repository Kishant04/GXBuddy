import 'mascot_model.dart';
import 'alert_model.dart';

/// Request body for POST /api/transactions.
class TransactionCreateRequest {
  const TransactionCreateRequest({
    required this.amount,
    required this.merchant,
    this.userId,
    this.category,
    this.source = 'MANUAL',
    this.status = 'POSTED',
    this.externalRef,
    this.isBnpl = false,
    this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        if (userId != null) 'user_id': userId,
        'amount': amount,
        'merchant': merchant,
        if (category != null) 'category': category,
        'source': source,
        'status': status,
        if (externalRef != null) 'external_ref': externalRef,
        'is_bnpl': isBnpl,
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      };

  final String? userId;
  final double amount;
  final String merchant;
  final String? category;
  final String source;
  final String status;
  final String? externalRef;
  final bool isBnpl;
  final DateTime? timestamp;
}

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
    this.userId,
    this.riskScore,
    this.source,
    this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Backend key is 'merchant'; local demo data uses 'name'.
    final rawName =
        json['merchant'] as String? ?? json['name'] as String? ?? '';
    final rawCategory =
        json['category'] as String? ?? json['category_name'] as String? ?? '';
    final riskScore = (json['risk_score'] as num?)?.toDouble();

    return TransactionModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String?,
      name: rawName,
      amount: _toDouble(json['amount']),
      category: _toDisplayCategory(rawCategory),
      riskLabel: json['risk'] as String? ??
          json['risk_label'] as String? ??
          _riskLabelFrom(riskScore),
      timestamp: _parseDate(json['timestamp']),
      glyph: json['glyph'] as String? ?? _glyphFor(rawCategory),
      colorHex: json['color'] as String? ?? _colorFor(rawCategory),
      isIncome: json['income'] as bool? ??
          json['is_income'] as bool? ??
          _isIncomeCategory(rawCategory),
      riskScore: riskScore,
      source: json['source'] as String?,
      status: json['status'] as String?,
    );
  }

  final String id;
  final String? userId;
  final String name;
  final double amount;
  final String category;
  final String riskLabel;
  final DateTime timestamp;
  final String glyph;
  final String colorHex;
  final bool isIncome;
  final double? riskScore;
  final String? source;
  final String? status;

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    String? category,
    String? riskLabel,
    DateTime? timestamp,
    String? glyph,
    String? colorHex,
    bool? isIncome,
    double? riskScore,
    String? source,
    String? status,
  }) =>
      TransactionModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        riskLabel: riskLabel ?? this.riskLabel,
        timestamp: timestamp ?? this.timestamp,
        glyph: glyph ?? this.glyph,
        colorHex: colorHex ?? this.colorHex,
        isIncome: isIncome ?? this.isIncome,
        riskScore: riskScore ?? this.riskScore,
        source: source ?? this.source,
        status: status ?? this.status,
      );

  // ── Derivation helpers ────────────────────────────────────

  static String _glyphFor(String? raw) => switch (raw?.toUpperCase()) {
        'FOOD' => '🍔',
        'TRANSPORT' => '🚗',
        'SHOPPING' => '🛍',
        'ENTERTAINMENT' => '🎬',
        'BILLS' => '📋',
        'HEALTH' => '💊',
        'EDUCATION' => '📚',
        'GROCERIES' => '🛒',
        'SAVINGS' => '💰',
        'SALARY' => '💸',
        _ => '📝',
      };

  static String _colorFor(String? raw) => switch (raw?.toUpperCase()) {
        'FOOD' => '#10B981',
        'TRANSPORT' => '#3B82F6',
        'SHOPPING' => '#F8326D',
        'ENTERTAINMENT' => '#8B5CF6',
        'BILLS' => '#F59E0B',
        'HEALTH' => '#EF4444',
        'EDUCATION' => '#06B6D4',
        'GROCERIES' => '#22C55E',
        'SAVINGS' => '#1FB287',
        'SALARY' => '#7C3AED',
        _ => '#771FFF',
      };

  static String _riskLabelFrom(double? score) {
    if (score == null) return 'Safe';
    if (score >= 70) return 'Risky';
    if (score >= 40) return 'Alert';
    return 'Safe';
  }

  static bool _isIncomeCategory(String? raw) => raw?.toUpperCase() == 'SALARY';

  static String _toDisplayCategory(String? raw) {
    if (raw == null || raw.isEmpty) return 'Other';
    return switch (raw.toUpperCase()) {
      'SALARY' => 'Income',
      'ENTERTAINMENT' => 'Lifestyle',
      String c => c[0].toUpperCase() + c.substring(1).toLowerCase(),
    };
  }
}

/// Full transaction processing response from POST /api/transactions.
class TransactionResponse {
  const TransactionResponse({
    required this.transaction,
    required this.classification,
    required this.riskScore,
    required this.mascot,
    this.alert,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) =>
      TransactionResponse(
        transaction: TransactionModel.fromJson(
            json['transaction'] as Map<String, dynamic>),
        classification: json['classification'] as String? ?? '',
        riskScore: (json['risk_score'] as num?)?.toDouble() ?? 0,
        mascot:
            MascotModel.fromJson(json['mascot'] as Map<String, dynamic>? ?? {}),
        alert: json['alert'] != null
            ? AlertModel.fromJson(json['alert'] as Map<String, dynamic>)
            : null,
      );

  final TransactionModel transaction;
  final String classification;
  final double riskScore;
  final MascotModel mascot;
  final AlertModel? alert;
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

DateTime _parseDate(dynamic v) {
  if (v == null) return DateTime.now();
  if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
  return DateTime.now();
}

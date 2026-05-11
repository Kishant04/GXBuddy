class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.monthlyIncome,
    required this.salaryThreshold,
    required this.level,
    required this.streakDays,
    required this.pushEnabled,
    required this.whatsappEnabled,
    required this.telegramEnabled,
    required this.anonymousSquad,
    required this.hideBalances,
    this.cardFrozen = false,
    this.weeklySpendingLimit = 0.0,
    this.email,
    this.squadId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? json['user_id'] ?? '',
        name: json['name'] as String? ??
            json['display_name'] as String? ??
            'User',
        email: json['email'] as String?,
        monthlyIncome: _toDouble(json['monthly_income']),
        salaryThreshold:
            _toDouble(json['salary_threshold'] ?? json['salarythreshold']),
        level: json['level'] as int? ?? 1,
        streakDays: json['current_streak'] as int? ?? json['streak_days'] as int? ?? 0,
        pushEnabled: json['push_notifications_enabled'] as bool? ?? json['push_enabled'] as bool? ?? true,
        whatsappEnabled: json['whatsapp_alerts_enabled'] as bool? ?? json['whatsapp_enabled'] as bool? ?? false,
        telegramEnabled: json['telegram_alerts_enabled'] as bool? ?? json['telegram_enabled'] as bool? ?? false,
        anonymousSquad: json['anonymous_squad_progress'] as bool? ?? json['anonymous_squad'] as bool? ?? false,
        hideBalances: json['hide_exact_balances'] as bool? ?? json['hide_balances'] as bool? ?? true,
        cardFrozen: json['card_frozen'] as bool? ?? false,
        weeklySpendingLimit: _toDouble(json['spending_limit'] ?? json['weekly_spending_limit']),
        squadId: json['squad_id'] as String?,
      );

  final String id;
  final String name;
  final String? email;
  final double monthlyIncome;
  final double salaryThreshold;
  final int level;
  final int streakDays;
  final bool pushEnabled;
  final bool whatsappEnabled;
  final bool telegramEnabled;
  final bool anonymousSquad;
  final bool hideBalances;
  final bool? cardFrozen;
  final double? weeklySpendingLimit;
  final String? squadId;

  String get shortName => name.split(' ').first;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    double? monthlyIncome,
    double? salaryThreshold,
    int? level,
    int? streakDays,
    bool? pushEnabled,
    bool? whatsappEnabled,
    bool? telegramEnabled,
    bool? anonymousSquad,
    bool? hideBalances,
    bool? cardFrozen,
    double? weeklySpendingLimit,
    String? squadId,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        monthlyIncome: monthlyIncome ?? this.monthlyIncome,
        salaryThreshold: salaryThreshold ?? this.salaryThreshold,
        level: level ?? this.level,
        streakDays: streakDays ?? this.streakDays,
        pushEnabled: pushEnabled ?? this.pushEnabled,
        whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
        telegramEnabled: telegramEnabled ?? this.telegramEnabled,
        anonymousSquad: anonymousSquad ?? this.anonymousSquad,
        hideBalances: hideBalances ?? this.hideBalances,
        cardFrozen: cardFrozen ?? this.cardFrozen,
        weeklySpendingLimit: weeklySpendingLimit ?? this.weeklySpendingLimit,
        squadId: squadId ?? this.squadId,
      );
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

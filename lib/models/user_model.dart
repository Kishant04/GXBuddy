class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.monthlyIncome,
    required this.level,
    required this.streakDays,
    required this.pushEnabled,
    required this.whatsappEnabled,
    required this.telegramEnabled,
    required this.anonymousSquad,
    required this.hideBalances,
    this.email,
    this.squadId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ??
            json['display_name'] as String? ??
            'User',
        email: json['email'] as String?,
        monthlyIncome: _toDouble(json['monthly_income']),
        level: json['level'] as int? ?? 1,
        streakDays: json['streak_days'] as int? ?? 0,
        pushEnabled: json['push_enabled'] as bool? ?? true,
        whatsappEnabled: json['whatsapp_enabled'] as bool? ?? true,
        telegramEnabled: json['telegram_enabled'] as bool? ?? false,
        anonymousSquad: json['anonymous_squad'] as bool? ?? false,
        hideBalances: json['hide_balances'] as bool? ?? true,
        squadId: json['squad_id'] as String?,
      );

  final String id;
  final String name;
  final String? email;
  final double monthlyIncome;
  final int level;
  final int streakDays;
  final bool pushEnabled;
  final bool whatsappEnabled;
  final bool telegramEnabled;
  final bool anonymousSquad;
  final bool hideBalances;
  final String? squadId;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    double? monthlyIncome,
    int? level,
    int? streakDays,
    bool? pushEnabled,
    bool? whatsappEnabled,
    bool? telegramEnabled,
    bool? anonymousSquad,
    bool? hideBalances,
    String? squadId,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        monthlyIncome: monthlyIncome ?? this.monthlyIncome,
        level: level ?? this.level,
        streakDays: streakDays ?? this.streakDays,
        pushEnabled: pushEnabled ?? this.pushEnabled,
        whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
        telegramEnabled: telegramEnabled ?? this.telegramEnabled,
        anonymousSquad: anonymousSquad ?? this.anonymousSquad,
        hideBalances: hideBalances ?? this.hideBalances,
        squadId: squadId ?? this.squadId,
      );
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

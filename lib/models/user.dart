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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? 'User',
        monthlyIncome: (json['monthly_income'] as num?)?.toDouble() ?? 0,
        level: json['level'] as int? ?? 1,
        streakDays: json['streak_days'] as int? ?? 0,
        pushEnabled: json['push_enabled'] as bool? ?? true,
        whatsappEnabled: json['whatsapp_enabled'] as bool? ?? true,
        telegramEnabled: json['telegram_enabled'] as bool? ?? false,
        anonymousSquad: json['anonymous_squad'] as bool? ?? false,
        hideBalances: json['hide_balances'] as bool? ?? true,
      );

  final String id;
  final String name;
  final double monthlyIncome;
  final int level;
  final int streakDays;
  final bool pushEnabled;
  final bool whatsappEnabled;
  final bool telegramEnabled;
  final bool anonymousSquad;
  final bool hideBalances;

  UserModel copyWith({
    String? id, String? name, double? monthlyIncome, int? level, int? streakDays,
    bool? pushEnabled, bool? whatsappEnabled, bool? telegramEnabled,
    bool? anonymousSquad, bool? hideBalances,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        monthlyIncome: monthlyIncome ?? this.monthlyIncome,
        level: level ?? this.level,
        streakDays: streakDays ?? this.streakDays,
        pushEnabled: pushEnabled ?? this.pushEnabled,
        whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
        telegramEnabled: telegramEnabled ?? this.telegramEnabled,
        anonymousSquad: anonymousSquad ?? this.anonymousSquad,
        hideBalances: hideBalances ?? this.hideBalances,
      );
}

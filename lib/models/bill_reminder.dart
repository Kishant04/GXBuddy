class BillReminder {
  const BillReminder({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDateLabel,
    required this.dueInDays,
    required this.icon,
  });

  factory BillReminder.fromJson(Map<String, dynamic> json) => BillReminder(
        id: json['id'] as String? ?? '',
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        dueDateLabel: json['due_date_label'] as String? ?? '',
        dueInDays: json['due_in_days'] as int? ?? 0,
        icon: json['icon'] as String? ?? '📄',
      );

  final String id;
  final String name;
  final double amount;
  final String dueDateLabel;
  final int dueInDays;
  final String icon;

  bool get isUrgent => dueInDays <= 2;
}

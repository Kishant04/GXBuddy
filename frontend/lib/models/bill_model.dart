/// Backend-shaped bill model. Matches BillReminderResponse from the API.
/// For the legacy UI display model, see BillReminder.
class BillModel {
  const BillModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.daysRemaining,
    required this.isPaid,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        amount: _toDouble(json['amount']),
        dueDate: _parseDate(json['due_date']),
        daysRemaining: json['days_remaining'] as int? ?? 0,
        isPaid: json['is_paid'] as bool? ?? false,
      );

  final String id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final int daysRemaining;
  final bool isPaid;

  bool get isUrgent => daysRemaining <= 2 && !isPaid;

  // ── Display helpers used by UpcomingBillCard ──────────────

  /// Emoji icon derived from bill name keywords.
  String get icon {
    final l = name.toLowerCase();
    if (l.contains('phone') ||
        l.contains('celcom') ||
        l.contains('maxis') ||
        l.contains('digi') ||
        l.contains('yes ')) {
      return '📱';
    }
    if (l.contains('netflix') ||
        l.contains('spotify') ||
        l.contains('disney') ||
        l.contains('stream')) {
      return '🎬';
    }
    if (l.contains('electric') || l.contains('tnb') || l.contains('tenaga')) {
      return '⚡';
    }
    if (l.contains('water') || l.contains('laku') || l.contains('syabas')) {
      return '💧';
    }
    if (l.contains('wifi') ||
        l.contains('unifi') ||
        l.contains('internet') ||
        l.contains('broadband')) {
      return '📡';
    }
    if (l.contains('rent') || l.contains('sewa')) return '🏠';
    if (l.contains('insurance') || l.contains('takaful')) return '🛡️';
    return '📋';
  }

  /// Human-readable due date label, e.g. "10 May".
  String get dueDateLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dueDate.day} ${months[dueDate.month - 1]}';
  }
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

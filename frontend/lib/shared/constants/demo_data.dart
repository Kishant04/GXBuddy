import '../../models/transaction.dart';
import '../../models/budget.dart';
import '../../models/pocket.dart';
import '../../models/alert.dart';
import '../../models/bill_reminder.dart';
import '../../models/squad.dart';
import '../../models/squad_member.dart';
import '../../models/mascot.dart';
import '../../models/user.dart';
import '../../models/autopilot_rule.dart';

abstract final class DemoData {
  // ── User ─────────────────────────────────────────────────
  static const UserModel user = UserModel(
    id: 'u001',
    name: 'Aiman',
    monthlyIncome: 1200,
    salaryThreshold: 800,
    level: 4,
    streakDays: 8,
    pushEnabled: true,
    whatsappEnabled: true,
    telegramEnabled: false,
    anonymousSquad: false,
    hideBalances: true,
  );

  // ── Budget ────────────────────────────────────────────────
  static WeeklyBudget initialBudget = WeeklyBudget(
    totalSpent: 312.50,
    totalBudget: 400,
    categories: [
      const CategoryBudget(category: 'food', spent: 148, limit: 150),
      const CategoryBudget(category: 'transport', spent: 45, limit: 100),
      const CategoryBudget(category: 'shopping', spent: 119.50, limit: 150),
    ],
  );

  // ── Pockets ───────────────────────────────────────────────
  static List<PocketModel> initialPockets = const [
    PocketModel(
      id: 'p001',
      name: 'Emergency Fund',
      balance: 240,
      target: 580,
      colorHex: '#1FB287',
      icon: '🛟',
      note: 'Auto · 20% of salary',
      eta: 'Goal in 4 mo',
    ),
    PocketModel(
      id: 'p002',
      name: 'PTPTN',
      balance: 120,
      target: 500,
      colorHex: '#3B82F6',
      icon: '📚',
      note: 'Auto · 10% of salary',
      eta: 'Goal in 7 mo',
    ),
    PocketModel(
      id: 'p003',
      name: 'Travel',
      balance: 90,
      target: 300,
      colorHex: '#F8326D',
      icon: '✈️',
      note: 'Auto · 5% of salary',
      eta: 'Bali · Dec',
    ),
  ];

  // ── Autopilot ─────────────────────────────────────────────
  static AutopilotRule initialAutopilot = AutopilotRule(
    threshold: 800,
    incomeType: IncomeType.monthly,
    splitRule: SplitRuleType.percent,
    allocations: const [
      PocketAllocation(
          pocketName: 'Emergency Fund',
          value: 20,
          icon: '🛟',
          colorHex: '#22C796'),
      PocketAllocation(
          pocketName: 'PTPTN', value: 10, icon: '📚', colorHex: '#3B82F6'),
      PocketAllocation(
          pocketName: 'Travel', value: 5, icon: '✈️', colorHex: '#F8326D'),
    ],
  );

  // ── Transactions ──────────────────────────────────────────
  static List<TransactionModel> initialTransactions = [
    TransactionModel(
      id: 'tx001',
      name: 'GrabFood',
      amount: 32.00,
      category: 'Food',
      riskLabel: 'Risky',
      timestamp: _today(20, 42),
      glyph: '🍔',
      colorHex: '#10B981',
    ),
    TransactionModel(
      id: 'tx002',
      name: "Touch 'n Go",
      amount: 15.00,
      category: 'Transport',
      riskLabel: 'Essential',
      timestamp: _today(7, 30),
      glyph: 'T',
      colorHex: '#3B82F6',
    ),
    TransactionModel(
      id: 'tx003',
      name: 'Shopee',
      amount: 89.00,
      category: 'Shopping',
      riskLabel: 'Unusual',
      timestamp: _yesterday(23, 18),
      glyph: 'S',
      colorHex: '#F8326D',
    ),
    TransactionModel(
      id: 'tx004',
      name: 'Spotify',
      amount: 14.90,
      category: 'Lifestyle',
      riskLabel: 'Lifestyle',
      timestamp: _monday(9, 0),
      glyph: '♫',
      colorHex: '#1DB954',
    ),
    TransactionModel(
      id: 'tx005',
      name: 'Salary Credit',
      amount: 1200.00,
      category: 'Income',
      riskLabel: 'Income',
      timestamp: _lastWeek(),
      glyph: '💸',
      colorHex: '#7C3AED',
      isIncome: true,
    ),
    TransactionModel(
      id: 'tx006',
      name: 'GrabFood',
      amount: 28.50,
      category: 'Food',
      riskLabel: 'Risky',
      timestamp: _monday(13, 15),
      glyph: '🍔',
      colorHex: '#10B981',
    ),
  ];

  // ── Bills ─────────────────────────────────────────────────
  static const List<BillReminder> upcomingBills = [
    BillReminder(
      id: 'b001',
      name: 'Phone bill',
      amount: 68,
      dueDateLabel: '10 May',
      dueInDays: 2,
      icon: '📱',
    ),
    BillReminder(
      id: 'b002',
      name: 'Netflix',
      amount: 17,
      dueDateLabel: '15 May',
      dueInDays: 7,
      icon: '🎬',
    ),
  ];

  // ── Alerts ────────────────────────────────────────────────
  static const List<AlertModel> activeAlerts = [
    AlertModel(
      id: 'a001',
      message:
          'Third food delivery this week. Want to round up RM2 into Emergency Fund?',
      severity: AlertSeverity.alert,
      actionLabel: 'Round up RM2',
      actionAmount: 2,
      targetPocket: 'Emergency Fund',
    ),
  ];

  // ── Squad ─────────────────────────────────────────────────
  static SquadModel initialSquad = SquadModel(
    id: 'sq001',
    name: 'Broke No More Squad',
    goalDescription: 'Save RM500 in 30 days',
    goalAmount: 500,
    progressPercent: 64,
    daysLeft: 14,
    members: const [
      SquadMember(
        id: 'm001',
        displayName: 'Aiman',
        initials: 'A',
        progressPercent: 72,
        streakDays: 8,
        colorHex: '#A855F7',
        status: 'On track',
        isYou: true,
      ),
      SquadMember(
        id: 'm002',
        displayName: 'Mei',
        initials: 'M',
        progressPercent: 65,
        streakDays: 6,
        colorHex: '#1FB287',
        status: 'On track',
      ),
      SquadMember(
        id: 'm003',
        displayName: 'Kumar',
        initials: 'K',
        progressPercent: 51,
        streakDays: 5,
        colorHex: '#F8326D',
        status: 'Needs nudge',
      ),
      SquadMember(
        id: 'm004',
        displayName: 'Sarah',
        initials: 'S',
        progressPercent: 68,
        streakDays: 7,
        colorHex: '#3B82F6',
        status: 'On track',
      ),
    ],
    weeklyInsight:
        "You're on track, but Kumar may need a nudge to maintain the streak.",
    rewardDescription:
        'Hit a 30-day streak to unlock Grab vouchers and GXCoins.',
  );

  // ── Mascot ────────────────────────────────────────────────
  static const MascotModel initialMascot = MascotModel(
    state: MascotState.alert,
    moodLine: "You've used 78% of your food budget and it's only Wednesday 👀",
  );

  // ── Salary splits (internal reference only) ───────────────
  // ignore: unused_field
  static const List<_SalarySlot> _salarySplits = [
    _SalarySlot('Emergency Fund', 240, '🛟', '#22C796', 20),
    _SalarySlot('PTPTN', 120, '📚', '#3B82F6', 10),
    _SalarySlot('Travel', 60, '✈️', '#F8326D', 5),
  ];

  static const double salaryAmount = 1200;
  static const double totalSalarySplit = 420;

  // ── Helpers ───────────────────────────────────────────────
  static DateTime _today(int h, int m) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, h, m);
  }

  static DateTime _yesterday(int h, int m) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - 1, h, m);
  }

  static DateTime _monday(int h, int m) {
    final now = DateTime.now();
    final daysBack = (now.weekday - 1) % 7;
    return DateTime(now.year, now.month, now.day - daysBack, h, m);
  }

  static DateTime _lastWeek() {
    final now = DateTime.now();
    return now.subtract(const Duration(days: 7));
  }
}

class _SalarySlot {
  const _SalarySlot(
      this.name, this.amount, this.icon, this.colorHex, this.percent);
  final String name;
  final double amount;
  final String icon;
  final String colorHex;
  final int percent;
}

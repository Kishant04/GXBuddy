enum IncomeType { monthly, gig }
enum SplitRuleType { fixed, percent }

class PocketAllocation {
  const PocketAllocation({
    required this.pocketName,
    required this.value,
    required this.icon,
    required this.colorHex,
  });

  final String pocketName;
  final double value;
  final String icon;
  final String colorHex;

  PocketAllocation copyWith({String? pocketName, double? value, String? icon, String? colorHex}) =>
      PocketAllocation(
        pocketName: pocketName ?? this.pocketName,
        value: value ?? this.value,
        icon: icon ?? this.icon,
        colorHex: colorHex ?? this.colorHex,
      );
}

class AutopilotRule {
  const AutopilotRule({
    required this.threshold,
    required this.incomeType,
    required this.splitRule,
    required this.allocations,
    this.lastSplitAmount = 0,
    this.lastSplitId,
  });

  final double threshold;
  final IncomeType incomeType;
  final SplitRuleType splitRule;
  final List<PocketAllocation> allocations;
  final double lastSplitAmount;
  final String? lastSplitId;

  double totalSplitForSalary(double salary) => allocations.fold(0, (sum, a) {
        if (splitRule == SplitRuleType.percent) return sum + (salary * a.value / 100);
        return sum + a.value;
      });

  AutopilotRule copyWith({
    double? threshold, IncomeType? incomeType, SplitRuleType? splitRule,
    List<PocketAllocation>? allocations, double? lastSplitAmount, String? lastSplitId,
  }) =>
      AutopilotRule(
        threshold: threshold ?? this.threshold,
        incomeType: incomeType ?? this.incomeType,
        splitRule: splitRule ?? this.splitRule,
        allocations: allocations ?? this.allocations,
        lastSplitAmount: lastSplitAmount ?? this.lastSplitAmount,
        lastSplitId: lastSplitId ?? this.lastSplitId,
      );
}

class AutopilotSplitResult {
  const AutopilotSplitResult({
    required this.splitId,
    required this.totalAmount,
    required this.splits,
  });

  factory AutopilotSplitResult.fromJson(Map<String, dynamic> json) => AutopilotSplitResult(
        splitId: json['split_id'] as String,
        totalAmount: (json['total_amount'] as num).toDouble(),
        splits: (json['splits'] as List<dynamic>)
            .map((s) => SplitEntry.fromJson(s as Map<String, dynamic>))
            .toList(),
      );

  final String splitId;
  final double totalAmount;
  final List<SplitEntry> splits;
}

class SplitEntry {
  const SplitEntry({required this.pocketName, required this.amount});

  factory SplitEntry.fromJson(Map<String, dynamic> json) => SplitEntry(
        pocketName: json['pocket_name'] as String,
        amount: (json['amount'] as num).toDouble(),
      );

  final String pocketName;
  final double amount;
}

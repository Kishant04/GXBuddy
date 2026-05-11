import 'package:flutter/material.dart';
import '../../../models/budget.dart';
import '../../../core/theme/gx_colors.dart';
import '../../../core/utils/risk_helpers.dart';
import '../../../shared/widgets/gx_card.dart';
import '../../../shared/widgets/budget_progress_bar.dart';

class WeeklyBudgetCard extends StatelessWidget {
  const WeeklyBudgetCard({super.key, required this.budget});

  final WeeklyBudget budget;

  static const _icons = {'food': '🍜', 'transport': '🚌', 'shopping': '🛍️'};
  static const _colors = {
    'food': Color(0xFFF8326D),
    'transport': Color(0xFF3B82F6),
    'shopping': Color(0xFFA855F7),
  };

  @override
  Widget build(BuildContext context) {
    final pct = budget.overallPercent;
    final pctColor = RiskHelpers.budgetPercentColor(pct);

    return GXCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weekly spend',
                        style:
                            TextStyle(fontSize: 12, color: GXColors.textSoft)),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'RM${budget.totalSpent.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: GXColors.textWhite,
                              letterSpacing: -0.03,
                            ),
                          ),
                          if (budget.totalBudget > 0)
                            TextSpan(
                              text:
                                  ' / RM${budget.totalBudget.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: GXColors.textSoft,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (budget.totalBudget > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: pctColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: pctColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    '${budget.overallPercentInt}% used',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: pctColor == GXColors.success
                          ? const Color(0xFFFFB95C)
                          : pctColor,
                    ),
                  ),
                ),
            ],
          ),
          if (budget.totalBudget > 0) ...[
            const SizedBox(height: 14),
            BudgetProgressBar(
                value: budget.totalSpent, max: budget.totalBudget, height: 10),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('0%',
                    style: TextStyle(fontSize: 10.5, color: GXColors.textMute)),
                Text('60% calm',
                    style: TextStyle(fontSize: 10.5, color: GXColors.textMute)),
                Text('80% alert',
                    style: TextStyle(fontSize: 10.5, color: GXColors.textMute)),
                Text('100%',
                    style: TextStyle(fontSize: 10.5, color: GXColors.textMute)),
              ],
            ),
          ],
          if (budget.categories.isNotEmpty) ...[
            Divider(height: 32, color: GXColors.border),
            ...budget.categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CategoryRow(
                    icon: _icons[cat.category.toLowerCase()] ?? '💳',
                    tint:
                        _colors[cat.category.toLowerCase()] ?? GXColors.violet,
                    name: cat.category[0].toUpperCase() +
                        cat.category.substring(1),
                    spent: cat.spent,
                    limit: cat.limit,
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.icon,
    required this.tint,
    required this.name,
    required this.spent,
    required this.limit,
  });

  final String icon;
  final Color tint;
  final String name;
  final double spent;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final hasLimit = limit > 0;
    final pct = hasLimit ? (spent / limit).clamp(0.0, 1.5) : 0.0;
    final pctInt = (pct * 100).round().clamp(0, 999);
    final color = hasLimit
        ? RiskHelpers.budgetPercentColor(pct.clamp(0.0, 1.0))
        : GXColors.textSoft;

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: tint.withValues(alpha: 0.27)),
              ),
              child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: GXColors.textWhite)),
            ),
            Text(
              'RM${spent.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12, color: GXColors.textSoft),
            ),
            if (hasLimit) ...[
              Text(' / ${limit.toStringAsFixed(0)}',
                  style:
                      const TextStyle(fontSize: 12, color: GXColors.textMute)),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                child: Text(
                  '$pctInt%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: color),
                ),
              ),
            ],
          ],
        ),
        if (hasLimit) ...[
          const SizedBox(height: 6),
          BudgetProgressBar(
              value: spent,
              max: limit,
              height: 5,
              showThresholds: false,
              color: color),
        ],
      ],
    );
  }
}

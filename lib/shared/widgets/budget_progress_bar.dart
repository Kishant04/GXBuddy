import 'package:flutter/material.dart';
import '../../core/utils/risk_helpers.dart';

class BudgetProgressBar extends StatelessWidget {
  const BudgetProgressBar({
    super.key,
    required this.value,
    required this.max,
    this.height = 8,
    this.showThresholds = true,
    this.color,
    this.animate = true,
  });

  final double value;
  final double max;
  final double height;
  final bool showThresholds;
  final Color? color;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final pct = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;
    final resolvedColor = color ?? RiskHelpers.budgetPercentColor(pct);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: height,
          child: Stack(
            children: [
              // Track
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x0FFFFFFF),
                  borderRadius: BorderRadius.circular(height),
                  border: Border.all(color: const Color(0x0DFFFFFF)),
                ),
              ),
              // Fill
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height),
                    gradient: LinearGradient(
                      colors: [resolvedColor, resolvedColor.withValues(alpha: 0.85)],
                    ),
                    boxShadow: [
                      BoxShadow(color: resolvedColor.withValues(alpha: 0.55), blurRadius: 12),
                    ],
                  ),
                ),
              ),
              // Threshold markers
              if (showThresholds) ...[
                _marker(0.60, constraints.maxWidth),
                _marker(0.80, constraints.maxWidth),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _marker(double fraction, double totalWidth) => Positioned(
        left: totalWidth * fraction - 0.5,
        top: -2,
        bottom: -2,
        child: Container(
          width: 1,
          color: const Color(0x30FFFFFF),
        ),
      );
}

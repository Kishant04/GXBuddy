import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../core/theme/gx_colors.dart';
import '../../core/utils/risk_helpers.dart';
import '../../core/utils/date_helpers.dart';
import 'gx_card.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.tx});

  final TransactionModel tx;

  @override
  Widget build(BuildContext context) {
    final risk = RiskHelpers.fromString(tx.riskLabel);
    final riskColor = RiskHelpers.color(risk);
    final color = _parseColor(tx.colorHex);

    return GXCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Merchant icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.40), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: Center(
              child: Text(
                tx.glyph,
                style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tx.name,
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: GXColors.textWhite,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tx.isIncome
                          ? '+RM${tx.amount.toStringAsFixed(2)}'
                          : '-RM${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: tx.isIncome ? GXColors.success : GXColors.textWhite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${DateHelpers.relative(tx.timestamp)} · ${tx.category}',
                      style: const TextStyle(fontSize: 11, color: GXColors.textSoft),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: riskColor.withValues(alpha: 0.27)),
                      ),
                      child: Text(
                        tx.riskLabel,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: riskColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return GXColors.violet;
    }
  }
}

import 'package:flutter/material.dart';
import '../../models/pocket.dart';
import '../../core/theme/gx_colors.dart';
import 'gx_card.dart';
import 'budget_progress_bar.dart';

class PocketCard extends StatelessWidget {
  const PocketCard({super.key, required this.pocket});

  final PocketModel pocket;

  @override
  Widget build(BuildContext context) {
    final color = pocket.color;

    return GXCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Center(
                  child:
                      Text(pocket.icon, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pocket.name,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: GXColors.textWhite),
                    ),
                    Text(
                      pocket.note,
                      style: const TextStyle(
                          fontSize: 11.5, color: GXColors.textSoft),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'RM${pocket.balance.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: GXColors.textWhite),
                  ),
                  Text(
                    'of RM${pocket.target.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 10.5, color: GXColors.textMute),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          BudgetProgressBar(
            value: pocket.balance,
            max: pocket.target,
            height: 6,
            showThresholds: false,
            color: color,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${pocket.percentInt}% complete',
                style: const TextStyle(fontSize: 11, color: GXColors.textMute),
              ),
              Text(
                pocket.eta,
                style: const TextStyle(fontSize: 11, color: GXColors.textMute),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

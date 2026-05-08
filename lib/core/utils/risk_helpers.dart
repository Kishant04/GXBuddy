import 'package:flutter/material.dart';
import '../theme/gx_colors.dart';

enum RiskLevel { safe, essential, lifestyle, watch, unusual, risky, income }

abstract final class RiskHelpers {
  static RiskLevel fromString(String s) => switch (s.toLowerCase()) {
        'risky' => RiskLevel.risky,
        'unusual' => RiskLevel.unusual,
        'essential' => RiskLevel.essential,
        'lifestyle' => RiskLevel.lifestyle,
        'income' => RiskLevel.income,
        'watch' => RiskLevel.watch,
        _ => RiskLevel.safe,
      };

  static Color color(RiskLevel level) => switch (level) {
        RiskLevel.risky => GXColors.danger,
        RiskLevel.unusual => GXColors.warning,
        RiskLevel.watch => GXColors.warningLight,
        RiskLevel.essential => GXColors.success,
        RiskLevel.income => GXColors.success,
        RiskLevel.lifestyle => GXColors.textSoft,
        RiskLevel.safe => GXColors.textMute,
      };

  static String label(RiskLevel level) => switch (level) {
        RiskLevel.risky => 'Risky',
        RiskLevel.unusual => 'Unusual',
        RiskLevel.watch => 'Watch',
        RiskLevel.essential => 'Essential',
        RiskLevel.income => 'Income',
        RiskLevel.lifestyle => 'Lifestyle',
        RiskLevel.safe => 'Safe',
      };

  static Color budgetPercentColor(double pct) {
    if (pct >= 1.0) return GXColors.danger;
    if (pct >= 0.8) return GXColors.warning;
    if (pct >= 0.6) return const Color(0xFFEAB308);
    return GXColors.success;
  }
}

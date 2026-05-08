import 'package:flutter/material.dart';
import '../../models/alert.dart';
import '../../core/theme/gx_colors.dart';
import 'gx_button.dart';

class AlertCard extends StatelessWidget {
  const AlertCard({
    super.key,
    required this.alert,
    this.onAction,
    this.onDismiss,
  });

  final AlertModel alert;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  Color get _accentColor => switch (alert.severity) {
        AlertSeverity.danger => GXColors.danger,
        AlertSeverity.warning => GXColors.warning,
        AlertSeverity.alert => GXColors.pink,
        AlertSeverity.info => GXColors.violet,
      };

  String get _iconText => switch (alert.severity) {
        AlertSeverity.danger => '🚨',
        AlertSeverity.warning => '⚠️',
        AlertSeverity.alert => '👀',
        AlertSeverity.info => 'ℹ️',
      };

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withValues(alpha: 0.10), const Color(0x05FFFFFF)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.40)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.40), blurRadius: 28, offset: const Offset(0, 10))],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(_iconText, style: const TextStyle(fontSize: 17))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pattern Spotted',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accent, letterSpacing: 0.1),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: const TextStyle(fontSize: 13.5, color: GXColors.textWhite, height: 1.45),
                ),
                if (alert.actionLabel != null || onDismiss != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (alert.actionLabel != null)
                        GXButton(
                          label: alert.actionLabel!,
                          onPressed: onAction,
                          variant: GXButtonVariant.pink,
                          size: GXButtonSize.sm,
                        ),
                      if (alert.actionLabel != null && onDismiss != null)
                        const SizedBox(width: 8),
                      if (onDismiss != null)
                        GXButton(
                          label: 'Not now',
                          onPressed: onDismiss,
                          variant: GXButtonVariant.ghost,
                          size: GXButtonSize.sm,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

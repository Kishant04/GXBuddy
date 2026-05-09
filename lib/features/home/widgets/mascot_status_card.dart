import 'package:flutter/material.dart';
import '../../../models/mascot.dart';
import '../../../core/theme/gx_colors.dart';
import '../../../shared/widgets/gx_card.dart';
import '../../../shared/widgets/animated_mascot.dart';

class MascotStatusCard extends StatelessWidget {
  const MascotStatusCard({
    super.key,
    required this.mascotState,
    required this.streakDays,
    this.moodLine,
  });

  final MascotState mascotState;
  final int streakDays;

  /// AI-generated mood line from the API. Falls back to the enum extension
  /// string when null or empty (e.g. in offline / mock mode).
  final String? moodLine;

  Color get _glowColor => switch (mascotState) {
        MascotState.calm => GXColors.success,
        MascotState.alert => GXColors.warning,
        MascotState.panicked => GXColors.danger,
        MascotState.celebrating => GXColors.celebrationLight,
      };

  String get _resolvedMoodLine => (moodLine != null && moodLine!.isNotEmpty)
      ? moodLine!
      : mascotState.moodLine;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: GXCard(
        key: ValueKey(mascotState),
        glowColor: _glowColor,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            AnimatedMascot(state: mascotState, size: 96),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GXBuddy · ${mascotState.label}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: GXColors.textSoft,
                      letterSpacing: 0.12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _resolvedMoodLine,
                      key: ValueKey(_resolvedMoodLine),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: GXColors.textWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Pill(icon: '🔥', label: '${streakDays}d streak'),
                      const SizedBox(width: 6),
                      const _Pill(icon: '🛡️', label: 'Shield on'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0x12FFFFFF),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: GXColors.textWhite)),
          ],
        ),
      );
}

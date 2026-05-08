import 'package:flutter/material.dart';
import '../../core/theme/gx_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x000C0121), Color(0xFF0C0121)],
          stops: [0.0, 0.35],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: _NavIcons.home, label: 'Home', index: 0, current: currentIndex, onTap: onTap),
              _NavItem(icon: _NavIcons.spend, label: 'Spend', index: 1, current: currentIndex, onTap: onTap),
              _NavItem(icon: _NavIcons.pockets, label: 'Pockets', index: 2, current: currentIndex, onTap: onTap),
              _NavItem(icon: _NavIcons.squad, label: 'Squad', index: 3, current: currentIndex, onTap: onTap),
              _NavItem(icon: _NavIcons.profile, label: 'Profile', index: 4, current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  final Widget Function(bool) icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (active)
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [GXColors.violet.withValues(alpha: 0.35), Colors.transparent],
                      ),
                    ),
                  ),
                icon(active),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5, fontWeight: FontWeight.w600,
                color: active ? GXColors.textWhite : GXColors.textMute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract final class _NavIcons {
  static Widget home(bool active) => Icon(
        active ? Icons.home_rounded : Icons.home_outlined,
        size: 22, color: active ? GXColors.violet : GXColors.textMute,
      );

  static Widget spend(bool active) => Icon(
        active ? Icons.credit_card : Icons.credit_card_outlined,
        size: 22, color: active ? GXColors.violet : GXColors.textMute,
      );

  static Widget pockets(bool active) => Icon(
        active ? Icons.savings : Icons.savings_outlined,
        size: 22, color: active ? GXColors.violet : GXColors.textMute,
      );

  static Widget squad(bool active) => Icon(
        active ? Icons.group : Icons.group_outlined,
        size: 22, color: active ? GXColors.violet : GXColors.textMute,
      );

  static Widget profile(bool active) => Icon(
        active ? Icons.person : Icons.person_outline,
        size: 22, color: active ? GXColors.violet : GXColors.textMute,
      );
}

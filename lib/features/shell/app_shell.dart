import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../core/theme/gx_colors.dart';
import '../../core/router/app_router.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = ['/home', '/spend', '/pockets', '/squad', '/profile'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((t) => location.startsWith(t)).clamp(0, 4);

    return Scaffold(
      backgroundColor: GXColors.bgPrimary,
      extendBody: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.3, -0.5),
                radius: 1.4,
                colors: [Color(0xFF1F0A4A), GXColors.bgPrimary, GXColors.bgSecondary],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          child,
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: index,
        onTap: (i) => context.goTab(i),
      ),
    );
  }
}

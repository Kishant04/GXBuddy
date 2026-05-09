import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/realtime/realtime_event.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/gx_colors.dart';
import '../../features/home/home_controller.dart';
import '../../features/spend/spend_controller.dart';
import '../../providers/websocket_provider.dart';
import '../../shared/widgets/app_bottom_nav.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = ['/home', '/spend', '/pockets', '/squad', '/profile'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((t) => location.startsWith(t)).clamp(0, 4);

    // ── WebSocket event handling ───────────────────────────────────────────────
    ref.listen<AsyncValue<RealtimeEvent>>(
      realtimeProvider,
      (_, next) {
        next.whenData((event) => _onWsEvent(context, ref, event));
      },
    );

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
                colors: [
                  Color(0xFF1F0A4A),
                  GXColors.bgPrimary,
                  GXColors.bgSecondary
                ],
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

  void _onWsEvent(BuildContext context, WidgetRef ref, RealtimeEvent event) {
    switch (event.type) {
      case RealtimeEventType.alert:
        // Refresh dashboard so the new alert appears.
        ref.invalidate(homeDashboardProvider);
        _showBanner(
          context,
          message: event.message ?? 'New alert',
          icon: '👀',
          color: GXColors.warning,
        );

      case RealtimeEventType.mascotState:
        // Mascot update — refresh dashboard to get new mood line.
        ref.invalidate(homeDashboardProvider);

      case RealtimeEventType.billWarning:
        ref.invalidate(homeDashboardProvider);
        _showBanner(
          context,
          message: event.message ??
              '${event.billName ?? 'A bill'} due in '
                  '${event.daysRemaining ?? 0} day(s)',
          icon: '📋',
          color: GXColors.warning,
        );

      case RealtimeEventType.transactionProcessed:
        ref.invalidate(homeDashboardProvider);
        ref.invalidate(transactionsProvider);

      case RealtimeEventType.streakShield:
        // Store the event — the squad screen will show the modal.
        ref.read(wsStreakShieldEventProvider.notifier).state = event;

      case RealtimeEventType.rally:
        final from = event.memberIndex;
        ref.read(wsRallyEventProvider.notifier).state = event;
        _showBanner(
          context,
          message: event.message ??
              'Hold Strong 💪 from '
                  '${from != null ? 'Member $from' : 'a teammate'}',
          icon: '💪',
          color: GXColors.success,
        );

      case RealtimeEventType.unknown:
        break; // silently ignore
    }
  }

  void _showBanner(
    BuildContext context, {
    required String message,
    required String icon,
    required Color color,
  }) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearMaterialBanners();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF14053A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withValues(alpha: 0.40)),
        ),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: color, blurRadius: 10)]),
            ),
            const SizedBox(width: 10),
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13, color: GXColors.textWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

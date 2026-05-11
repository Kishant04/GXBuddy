import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/home/home_screen.dart';
import '../../features/spend/spend_screen.dart';
import '../../features/pockets/pockets_screen.dart';
import '../../features/squad/squad_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/gxbank/gxbank_entry_screen.dart';
import '../../features/notifications/notification_preview_screen.dart';
import '../../providers/app_providers.dart';

/// Single router instance for the app lifetime.
/// Keys are module-level so they survive provider re-reads.
final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final appRouterProvider = Provider<GoRouter>((ref) {
  final tokenStore = ref.read(authTokenStoreProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: tokenStore.hasToken ? '/bank' : '/login',
    redirect: (context, state) {
      final hasToken = tokenStore.hasToken;
      final loc = state.matchedLocation;
      if (!hasToken && loc != '/login') return '/login';
      if (hasToken && loc == '/login') return '/bank';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/bank',
        builder: (_, __) => const GXBankEntryScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationPreviewScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/spend', builder: (_, __) => const SpendScreen()),
          GoRoute(path: '/pockets', builder: (_, __) => const PocketsScreen()),
          GoRoute(path: '/squad', builder: (_, __) => const SquadScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});

extension GoRouterX on BuildContext {
  void goTab(int index) {
    const paths = ['/home', '/spend', '/pockets', '/squad', '/profile'];
    go(paths[index]);
  }
}

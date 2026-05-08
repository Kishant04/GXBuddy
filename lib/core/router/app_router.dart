import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/shell/app_shell.dart';
import '../../features/home/home_screen.dart';
import '../../features/spend/spend_screen.dart';
import '../../features/pockets/pockets_screen.dart';
import '../../features/squad/squad_screen.dart';
import '../../features/profile/profile_screen.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/home',
  routes: [
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

extension GoRouterX on BuildContext {
  void goTab(int index) {
    const paths = ['/home', '/spend', '/pockets', '/squad', '/profile'];
    go(paths[index]);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';

/// Resolved user ID for API calls, in priority order:
///   1. Stored user ID from AuthTokenStore (set by /api/auth/me or dev settings)
///   2. Mock mode: 'demo_user' fallback so the app works without auth
///   3. null — home screen shows a setup card asking the user to enter their ID
final resolvedUserIdProvider = Provider<String?>((ref) {
  final stored = ref.watch(currentUserIdProvider);
  if (stored != null && stored.isNotEmpty) return stored;
  if (ref.watch(isMockModeProvider)) return 'demo_user';
  return null;
});

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/api_gx_repository.dart';
import '../repositories/gx_repository.dart';
import '../repositories/mock_gx_repository.dart';
import 'app_providers.dart';

/// The single source of truth for the data layer.
///
/// Returns [MockGxRepository] when mock mode is active (compile-time flag or
/// runtime override), otherwise [ApiGxRepository] backed by real HTTP + WS.
///
/// All feature controllers should read data through this provider rather than
/// constructing repositories or importing DemoData directly.
final repositoryProvider = Provider<GxRepository>((ref) {
  final useMock = ref.watch(isMockModeProvider);
  if (useMock) {
    debugPrint('[REPO] Using MockGxRepository');
    return MockGxRepository();
  }
  debugPrint('[REPO] Using ApiGxRepository');
  return ApiGxRepository(
    apiClient: ref.watch(apiClientProvider),
    wsService: ref.watch(wsServiceProvider),
  );
});

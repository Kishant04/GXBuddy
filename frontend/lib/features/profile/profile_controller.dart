import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';
import '../../providers/repository_provider.dart';
import '../../providers/user_id_provider.dart';

class ProfileNotifier extends StateNotifier<UserModel> {
  ProfileNotifier(this._ref)
      : super(const UserModel(
          id: '',
          name: '',
          monthlyIncome: 0,
          salaryThreshold: 0,
          level: 1,
          streakDays: 0,
          pushEnabled: true,
          whatsappEnabled: false,
          telegramEnabled: false,
          anonymousSquad: false,
          hideBalances: true,
        )) {
    // Watch user ID changes to trigger a load
    _ref.listen(resolvedUserIdProvider, (prev, next) {
      if (next != null) _load();
    }, fireImmediately: true);
  }

  final Ref _ref;

  Future<void> _load() async {
    final userId = _ref.read(resolvedUserIdProvider);
    if (userId == null) return;
    try {
      final user = await _ref.read(repositoryProvider).getUserProfile(userId: userId);
      if (mounted) state = user;
    } catch (_) {
      // silently keep empty state — user sees loading skeleton
    }
  }

  Future<void> _persist() async {
    try {
      await _ref.read(repositoryProvider).updateProfile(state);
    } catch (_) {
      // local state already updated; persist failure is non-fatal
    }
  }

  void togglePush() {
    state = state.copyWith(pushEnabled: !state.pushEnabled);
    _persist();
  }

  void toggleWhatsapp() {
    state = state.copyWith(whatsappEnabled: !state.whatsappEnabled);
    _persist();
  }

  void toggleTelegram() {
    state = state.copyWith(telegramEnabled: !state.telegramEnabled);
    _persist();
  }

  void toggleAnonymousSquad() {
    state = state.copyWith(anonymousSquad: !state.anonymousSquad);
    _persist();
  }

  void toggleHideBalances() {
    state = state.copyWith(hideBalances: !state.hideBalances);
    _persist();
  }

  void toggleFreezeCard() {
    state = state.copyWith(cardFrozen: !(state.cardFrozen ?? false));
    _persist();
  }

  void updateSpendingLimit(double limit) {
    state = state.copyWith(weeklySpendingLimit: limit);
    _persist();
  }

  Future<void> refresh() => _load();
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserModel>(
  (ref) => ProfileNotifier(ref),
);

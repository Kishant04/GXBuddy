import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../providers/repository_provider.dart';
import '../../providers/user_id_provider.dart';

class ProfileNotifier extends StateNotifier<UserModel> {
  ProfileNotifier(this._ref)
      : super(const UserModel(
          id: '',
          name: '',
          monthlyIncome: 0,
          level: 1,
          streakDays: 0,
          pushEnabled: true,
          whatsappEnabled: false,
          telegramEnabled: false,
          anonymousSquad: false,
          hideBalances: true,
        )) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final userId = _ref.read(resolvedUserIdProvider);
    if (userId == null) return;
    try {
      final user = await _ref.read(repositoryProvider).getUserProfile();
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

  // WhatsApp and Telegram are on hold — toggles are no-ops for now
  void toggleWhatsapp() {}
  void toggleTelegram() {}

  void toggleAnonymousSquad() {
    state = state.copyWith(anonymousSquad: !state.anonymousSquad);
    _persist();
  }

  void toggleHideBalances() {
    state = state.copyWith(hideBalances: !state.hideBalances);
    _persist();
  }

  Future<void> refresh() => _load();
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserModel>(
  (ref) => ProfileNotifier(ref),
);

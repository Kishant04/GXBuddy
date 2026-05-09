import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../shared/constants/demo_data.dart';

class ProfileNotifier extends StateNotifier<UserModel> {
  ProfileNotifier() : super(DemoData.user);

  void togglePush() => state = state.copyWith(pushEnabled: !state.pushEnabled);
  void toggleWhatsapp() =>
      state = state.copyWith(whatsappEnabled: !state.whatsappEnabled);
  void toggleTelegram() =>
      state = state.copyWith(telegramEnabled: !state.telegramEnabled);
  void toggleAnonymousSquad() =>
      state = state.copyWith(anonymousSquad: !state.anonymousSquad);
  void toggleHideBalances() =>
      state = state.copyWith(hideBalances: !state.hideBalances);
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserModel>(
  (_) => ProfileNotifier(),
);

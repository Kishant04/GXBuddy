import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'core/services/notification_service.dart';
import 'core/storage/auth_token_store.dart';
import 'providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));

  final prefs = await SharedPreferences.getInstance();
  final tokenStore = AuthTokenStore();
  await tokenStore.init();

  final notificationService = NotificationService(prefs);

  // Auto-seed credentials supplied via --dart-define at launch.
  // These override any previously stored values so each `flutter run`
  // command picks up fresh credentials without manual DevSettings entry.
  // Never hardcode real values — always pass them on the command line.
  if (AppConfig.devUserId.isNotEmpty) {
    await tokenStore.setUserId(AppConfig.devUserId);
  }
  if (AppConfig.devToken.isNotEmpty) {
    await tokenStore.setToken(AppConfig.devToken);
  }

  runApp(
    ProviderScope(
      overrides: [
        authTokenStoreProvider.overrideWithValue(tokenStore),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const GXBuddyApp(),
    ),
  );
}

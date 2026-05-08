import 'environment.dart';

abstract final class AppConfig {
  static const String appName = 'GXBuddy';
  static const String appVersion = '1.0.0';

  // Base URLs — swap these when backend is ready
  static const String _stagingBaseUrl = 'https://api.staging.gxbuddy.my';
  static const String _productionBaseUrl = 'https://api.gxbuddy.my';

  static String get baseUrl => switch (Environment.current) {
        AppEnvironment.mock => 'http://localhost:8000',
        AppEnvironment.staging => _stagingBaseUrl,
        AppEnvironment.production => _productionBaseUrl,
      };

  static String get wsBaseUrl =>
      baseUrl.replaceFirst('http', 'ws').replaceFirst('https', 'wss');

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

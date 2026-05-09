import 'app_config.dart';

enum AppEnvironment { mock, staging, production }

abstract final class Environment {
  static AppEnvironment get current =>
      AppConfig.useMockData ? AppEnvironment.mock : AppEnvironment.production;

  static bool get isMock => AppConfig.useMockData;
  static bool get isProduction => !AppConfig.useMockData;
}

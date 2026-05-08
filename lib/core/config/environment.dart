enum AppEnvironment { mock, staging, production }

abstract final class Environment {
  static const AppEnvironment current = AppEnvironment.mock;

  static bool get isMock => current == AppEnvironment.mock;
  static bool get isProduction => current == AppEnvironment.production;
}

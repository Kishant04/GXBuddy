// All API endpoint paths. No logic — strings only.
abstract final class Endpoints {
  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // Dashboard
  static const String dashboard = '/api/dashboard';

  // Transactions
  static const String transactions = '/api/transactions';

  // Budgets
  static const String budgets = '/api/budgets';

  // Pockets
  static const String pockets = '/api/pockets';

  // Autopilot
  static const String autopilotTrigger = '/api/autopilot/trigger';
  static const String autopilotUndo = '/api/autopilot/undo';

  // Squad
  static String squad(String id) => '/api/squad/$id';
  static String squadRally(String id) => '/api/squad/$id/rally';

  // Profile
  static const String profile = '/api/profile';

  // WebSocket
  static const String ws = '/ws';
}

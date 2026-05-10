/// All API path constants. No logic — strings only.
///
/// Naming rule: path segments map to field names.
/// Query parameters are NOT included here — callers add them.
abstract final class Endpoints {
  // ── Auth ──────────────────────────────────────────────────
  static const String authHealth = '/api/auth/health';

  /// POST {email, password} → {access_token, user_id, email}
  static const String authLogin = '/api/auth/login';

  /// Returns {user: {id, email}} for the authenticated user.
  static const String authMe = '/api/auth/me';

  // ── Dashboard ─────────────────────────────────────────────
  /// GET ?user_id=
  static const String dashboard = '/api/dashboard';

  // ── Transactions ──────────────────────────────────────────
  /// GET ?user_id=&limit=   POST (Bearer)
  static const String transactions = '/api/transactions';

  // ── Budgets ───────────────────────────────────────────────
  /// Note: backend router prefix is /budgets — no /api/ prefix.
  /// GET ?user_id=   POST
  static const String budgets = '/budgets';

  // ── Bills ─────────────────────────────────────────────────
  /// Note: backend router prefix is /bills — no /api/ prefix.
  /// GET ?user_id=&days_ahead=
  static const String bills = '/bills';

  // ── Pockets ───────────────────────────────────────────────
  /// GET / POST (Bearer)
  static const String pockets = '/api/pockets';

  /// PATCH / DELETE (Bearer)
  static String pocket(String id) => '/api/pockets/$id';

  // ── Autopilot ─────────────────────────────────────────────
  static const String autopilotHealth = '/api/autopilot/health';

  /// POST (Bearer) — body: {transaction_id}
  static const String autopilotTrigger = '/api/autopilot/trigger';

  /// POST (Bearer) — body: {split_id}
  static const String autopilotUndo = '/api/autopilot/undo';

  /// GET (Bearer) — returns {message}
  static const String autopilotUndoContext = '/api/autopilot/undo-context';

  // ── Squad ─────────────────────────────────────────────────
  /// POST (Bearer) — create squad
  static const String squadCreate = '/api/squad';

  /// POST (Bearer) — body: {invite_code}
  static const String squadJoin = '/api/squad/join';

  /// GET (Bearer)
  static String squad(String id) => '/api/squad/$id';

  /// POST (Bearer) — body: {target_member_index}
  static String squadRally(String id) => '/api/squad/$id/rally';

  // ── Alerts (planned endpoint — no backend router yet) ────────
  /// GET ?user_id=&severity=&limit=
  static const String alerts = '/api/alerts';

  /// POST — mark alert as actioned
  static String alertAction(String id) => '/api/alerts/$id/action';

  // ── WebSocket ─────────────────────────────────────────────
  /// Used as a path reference. Full URL is built from AppConfig.wsUrl.
  /// Connection: ws://host/ws?token={jwt}
  static const String ws = '/ws';

  // ── Profile ───────────────────────────────────────────────
  /// GET / PATCH (Bearer) — user profile
  static const String userProfile = '/api/profile';

  // ── Insights ──────────────────────────────────────────────
  /// GET ?user_id= — AI-generated spend insight
  static const String spendInsight = '/api/insights';

  // ── Legacy aliases (kept for backward compat) ─────────────

  /// Alias for [authMe]. GET /api/auth/me
  // ignore: non_constant_identifier_names
  static const String profile = authMe;
}

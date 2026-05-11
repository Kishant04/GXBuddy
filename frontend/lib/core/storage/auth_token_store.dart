import 'package:shared_preferences/shared_preferences.dart';

/// Persists the auth token, user ID, and optional URL overrides using
/// SharedPreferences. Values are cached in-memory after [init] so all
/// synchronous reads are instant.
///
/// Call [init] once before [runApp] (in main.dart).
class AuthTokenStore {
  static const _kToken = 'gx.auth_token';
  static const _kUserId = 'gx.user_id';
  static const _kSquadId = 'gx.squad_id';
  static const _kDemoResetKey = 'gx.demo_reset_key';
  static const _kApiBaseUrl = 'gx.api_base_url';
  static const _kWsUrl = 'gx.ws_url';
  static const _kMockMode = 'gx.mock_mode';

  String? _token;
  String? _userId;
  String? _squadId;
  String? _demoResetKey;
  String? _apiBaseUrlOverride;
  String? _wsUrlOverride;
  bool? _mockModeOverride;

  /// Load persisted values into the in-memory cache.
  /// Must be awaited before the app reads any token.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kToken);
    _userId = prefs.getString(_kUserId);
    _squadId = prefs.getString(_kSquadId);
    _demoResetKey = prefs.getString(_kDemoResetKey);
    _apiBaseUrlOverride = prefs.getString(_kApiBaseUrl);
    _wsUrlOverride = prefs.getString(_kWsUrl);
    _mockModeOverride = prefs.getBool(_kMockMode);
  }

  // ── Token ─────────────────────────────────────────────────

  String? get token => _token;
  bool get hasToken => _token != null && _token!.isNotEmpty;

  /// Returns a safe display string — never logs the real token.
  /// Format: "eyJ****abcd" (first 8 + **** + last 8 chars).
  String get maskedToken => _mask(_token);

  String _mask(String? t) {
    if (t == null || t.isEmpty) return '(none)';
    if (t.length < 16) return '****';
    return '${t.substring(0, 8)}****${t.substring(t.length - 8)}';
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
  }

  // ── User ID ───────────────────────────────────────────────

  String? get userId => _userId;

  Future<void> setUserId(String id) async {
    _userId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserId, id);
  }

  Future<void> clearUserId() async {
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserId);
  }

  // ── Squad ID ──────────────────────────────────────────────

  String? get squadId => _squadId;

  Future<void> setSquadId(String id) async {
    _squadId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSquadId, id);
  }

  Future<void> clearSquadId() async {
    _squadId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSquadId);
  }

  // ── Demo Reset Key ────────────────────────────────────────

  String? get demoResetKey => _demoResetKey;
  String get maskedDemoResetKey => _mask(_demoResetKey);

  Future<void> setDemoResetKey(String key) async {
    _demoResetKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDemoResetKey, key);
  }

  Future<void> clearDemoResetKey() async {
    _demoResetKey = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDemoResetKey);
  }

  // ── URL overrides (useful for dev/QA builds) ─────────────


  String? get apiBaseUrlOverride => _apiBaseUrlOverride;
  String? get wsUrlOverride => _wsUrlOverride;

  Future<void> setApiBaseUrl(String url) async {
    _apiBaseUrlOverride = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kApiBaseUrl, url);
  }

  Future<void> clearApiBaseUrl() async {
    _apiBaseUrlOverride = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kApiBaseUrl);
  }

  Future<void> setWsUrl(String url) async {
    _wsUrlOverride = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kWsUrl, url);
  }

  Future<void> clearWsUrl() async {
    _wsUrlOverride = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kWsUrl);
  }

  // ── Mock mode runtime toggle ──────────────────────────────

  /// Runtime override for mock mode. Takes precedence over the compile-time
  /// AppConfig.useMockData flag. Useful for toggling mock mode from a
  /// debug menu without rebuilding.
  bool? get mockModeOverride => _mockModeOverride;

  Future<void> setMockMode(bool value) async {
    _mockModeOverride = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMockMode, value);
  }

  Future<void> clearMockMode() async {
    _mockModeOverride = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kMockMode);
  }

  // ── Sign-out helper ───────────────────────────────────────

  /// Clears auth credentials (token + user ID + squad ID). Preserves URL overrides.
  Future<void> clearSession() async {
    await clearToken();
    await clearUserId();
    await clearSquadId();
  }

  /// Clears everything — tokens, user ID, squad ID, and all overrides.
  Future<void> clearAll() async {
    _token = null;
    _userId = null;
    _squadId = null;
    _demoResetKey = null;
    _apiBaseUrlOverride = null;
    _wsUrlOverride = null;
    _mockModeOverride = null;
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      _kToken,
      _kUserId,
      _kSquadId,
      _kDemoResetKey,
      _kApiBaseUrl,
      _kWsUrl,
      _kMockMode,
    ]) {
      await prefs.remove(key);
    }
  }
}

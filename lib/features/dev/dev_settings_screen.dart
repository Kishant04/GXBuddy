import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/endpoints.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/gx_colors.dart';
import '../../features/home/home_controller.dart';
import '../../features/pockets/pockets_controller.dart';
import '../../features/spend/spend_controller.dart';
import '../../features/squad/squad_controller.dart';
import '../../providers/app_providers.dart';
import '../../providers/repository_provider.dart';
import '../../providers/user_id_provider.dart';

/// Developer Settings — not shown in production builds.
/// Accessible from Profile → Developer Settings row.
class DevSettingsScreen extends ConsumerStatefulWidget {
  const DevSettingsScreen({super.key});

  @override
  ConsumerState<DevSettingsScreen> createState() => _DevSettingsScreenState();
}

class _DevSettingsScreenState extends ConsumerState<DevSettingsScreen> {
  late final TextEditingController _apiUrlCtrl;
  late final TextEditingController _wsUrlCtrl;
  late final TextEditingController _userIdCtrl;
  late final TextEditingController _tokenCtrl;

  bool _mockMode = false;
  bool _tokenObscured = true;

  // Test status
  String? _connStatus;
  bool _connOk = false;
  bool _connLoading = false;

  String? _authStatus;
  bool _authOk = false;
  bool _authLoading = false;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final store = ref.read(authTokenStoreProvider);
    _apiUrlCtrl = TextEditingController(text: store.apiBaseUrlOverride ?? '');
    _wsUrlCtrl = TextEditingController(text: store.wsUrlOverride ?? '');
    _userIdCtrl = TextEditingController(text: store.userId ?? '');
    // Pre-fill token field with stored token (obscured by default).
    _tokenCtrl = TextEditingController(text: store.token ?? '');
    _mockMode = store.mockModeOverride ?? AppConfig.useMockData;
  }

  @override
  void dispose() {
    _apiUrlCtrl.dispose();
    _wsUrlCtrl.dispose();
    _userIdCtrl.dispose();
    _tokenCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String get _effectiveApiUrl {
    final t = _apiUrlCtrl.text.trim();
    return t.isNotEmpty ? t : AppConfig.apiBaseUrl;
  }

  String _maskToken(String? t) {
    if (t == null || t.isEmpty) return '(none)';
    if (t.length < 16) return '****';
    return '${t.substring(0, 8)}****${t.substring(t.length - 8)}';
  }

  // ── Actions ───────────────────────────────────────────────────────────────────

  Future<void> _testConnection() async {
    setState(() {
      _connLoading = true;
      _connStatus = null;
    });
    try {
      final dio = Dio(BaseOptions(
        baseUrl: _effectiveApiUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
      ));
      final res = await dio.get(Endpoints.authHealth);
      setState(() {
        _connOk = res.statusCode == 200;
        _connStatus = '${res.statusCode == 200 ? '✓' : '✗'}  '
            '${res.statusCode} · ${res.data}';
      });
    } on DioException catch (e) {
      setState(() {
        _connOk = false;
        _connStatus =
            '✗  ${e.type.name} — ${e.message ?? 'No response from backend'}';
      });
    } catch (e) {
      setState(() {
        _connOk = false;
        _connStatus = '✗  $e';
      });
    } finally {
      setState(() => _connLoading = false);
    }
  }

  Future<void> _testAuth() async {
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) {
      setState(() {
        _authOk = false;
        _authStatus = '✗  No token entered. Paste your Supabase JWT above.';
      });
      return;
    }
    setState(() {
      _authLoading = true;
      _authStatus = null;
    });
    try {
      final dio = Dio(BaseOptions(
        baseUrl: _effectiveApiUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {'Authorization': 'Bearer ${_maskToken(token)}…'},
      ));
      // Attach real token without logging it
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (opts, handler) {
          opts.headers['Authorization'] = 'Bearer $token';
          handler.next(opts);
        },
      ));
      final res = await dio.get(Endpoints.authMe);
      final data = res.data as Map<String, dynamic>? ?? {};
      final user = data['user'] as Map<String, dynamic>? ?? data;
      final id = user['id'] ?? user['sub'] ?? '?';
      final email = user['email'] ?? '';
      setState(() {
        _authOk = true;
        _authStatus = '✓  id: $id\n   email: $email';
      });
    } on DioException catch (e) {
      setState(() {
        _authOk = false;
        _authStatus = e.response?.statusCode == 401
            ? '✗  401 Unauthorized — token is invalid or expired.'
            : '✗  ${e.type.name} — ${e.message ?? 'Failed'}';
      });
    } catch (e) {
      setState(() {
        _authOk = false;
        _authStatus = '✗  $e';
      });
    } finally {
      setState(() => _authLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    final store = ref.read(authTokenStoreProvider);

    final apiUrl = _apiUrlCtrl.text.trim();
    final wsUrl = _wsUrlCtrl.text.trim();
    final userId = _userIdCtrl.text.trim();
    final token = _tokenCtrl.text.trim();

    // URL overrides — clear if blank or equals the compile-time default
    if (apiUrl.isEmpty || apiUrl == AppConfig.apiBaseUrl) {
      await store.clearApiBaseUrl();
    } else {
      await store.setApiBaseUrl(apiUrl);
    }

    if (wsUrl.isEmpty || wsUrl == AppConfig.wsUrl) {
      await store.clearWsUrl();
    } else {
      await store.setWsUrl(wsUrl);
    }

    // User ID
    if (userId.isNotEmpty) {
      await store.setUserId(userId);
    }

    // Token — only save if non-empty to avoid accidentally clearing a stored token
    if (token.isNotEmpty) {
      await store.setToken(token);
    }

    // Mock mode
    await store.setMockMode(_mockMode);

    // Invalidate all data providers so they reload with new settings.
    ref.invalidate(currentUserIdProvider);
    ref.invalidate(resolvedUserIdProvider);
    ref.invalidate(isMockModeProvider);
    ref.invalidate(apiClientProvider);
    ref.invalidate(wsServiceProvider);
    ref.invalidate(repositoryProvider);
    ref.invalidate(homeDashboardProvider);
    ref.invalidate(transactionsProvider);
    ref.invalidate(pocketsAsyncProvider);
    ref.invalidate(squadNotifierProvider);

    setState(() => _saving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF14053A),
          behavior: SnackBarBehavior.floating,
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: GXColors.success, size: 16),
              SizedBox(width: 8),
              Text('Settings saved. Providers reloaded.',
                  style: TextStyle(color: GXColors.textWhite)),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: GXColors.success),
          ),
        ),
      );
    }
  }

  Future<void> _clearToken() async {
    final store = ref.read(authTokenStoreProvider);
    await store.clearSession();
    _tokenCtrl.clear();
    _userIdCtrl.clear();
    ref.invalidate(currentUserIdProvider);
    ref.invalidate(resolvedUserIdProvider);
    ref.invalidate(homeDashboardProvider);
    ref.invalidate(transactionsProvider);
    if (mounted) {
      setState(() {
        _authStatus = null;
        _connStatus = null;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    ref.invalidate(homeDashboardProvider);
    ref.invalidate(transactionsProvider);
    ref.invalidate(pocketsAsyncProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF14053A),
          behavior: SnackBarBehavior.floating,
          content: const Text(
              'Dashboard providers invalidated — reload home screen.',
              style: TextStyle(color: GXColors.textWhite, fontSize: 13)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: GXColors.violet),
          ),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(authTokenStoreProvider);
    final savedMasked = _maskToken(store.token);
    final savedUserId = store.userId ?? '(none)';

    return Scaffold(
      backgroundColor: GXColors.bgPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.3, -0.5),
            radius: 1.4,
            colors: [
              Color(0xFF1F0A4A),
              GXColors.bgPrimary,
              GXColors.bgSecondary
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: GXColors.textWhite, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Developer Settings',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: GXColors.textWhite,
                          letterSpacing: -0.02,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: GXColors.violet.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                            color: GXColors.violet.withValues(alpha: 0.40)),
                      ),
                      child: const Text('DEV ONLY',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: GXColors.violetLight,
                              letterSpacing: 0.10)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Status banner ─────────────────────────────────────
                      _StatusBanner(store: store),
                      const SizedBox(height: 20),

                      // ── Connection ────────────────────────────────────────
                      _sectionLabel('🌐  Connection'),
                      _Card(
                        child: Column(
                          children: [
                            _Field(
                              label: 'API Base URL',
                              controller: _apiUrlCtrl,
                              hint: AppConfig.apiBaseUrl,
                              hint2:
                                  'Override — leave blank to use compile-time default',
                            ),
                            _Divider(),
                            _Field(
                              label: 'WebSocket URL',
                              controller: _wsUrlCtrl,
                              hint: AppConfig.wsUrl,
                              hint2:
                                  'Override — leave blank to use compile-time default',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ActionButton(
                        label: 'Test Backend Connection',
                        icon: Icons.wifi_rounded,
                        loading: _connLoading,
                        onTap: _testConnection,
                      ),
                      if (_connStatus != null) ...[
                        const SizedBox(height: 8),
                        _StatusChip(text: _connStatus!, ok: _connOk),
                      ],
                      const SizedBox(height: 20),

                      // ── Authentication ────────────────────────────────────
                      _sectionLabel('🔑  Authentication'),
                      _Card(
                        child: Column(
                          children: [
                            _Field(
                              label: 'User ID',
                              controller: _userIdCtrl,
                              hint: 'Supabase user UUID',
                              hint2: 'Saved: $savedUserId',
                            ),
                            _Divider(),
                            _TokenField(
                              controller: _tokenCtrl,
                              obscured: _tokenObscured,
                              onToggleObscure: () => setState(
                                  () => _tokenObscured = !_tokenObscured),
                              savedMasked: savedMasked,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              label: 'Test Auth /me',
                              icon: Icons.verified_user_rounded,
                              loading: _authLoading,
                              onTap: _testAuth,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ActionButton(
                              label: 'Clear Token',
                              icon: Icons.logout_rounded,
                              color: GXColors.danger,
                              onTap: _clearToken,
                            ),
                          ),
                        ],
                      ),
                      if (_authStatus != null) ...[
                        const SizedBox(height: 8),
                        _StatusChip(text: _authStatus!, ok: _authOk),
                      ],
                      const SizedBox(height: 20),

                      // ── Run mode ──────────────────────────────────────────
                      _sectionLabel('⚙️  Run Mode'),
                      _Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Mock Mode',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: GXColors.textWhite)),
                                    Text(
                                      'No network calls — uses DemoData',
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          color: GXColors.textSoft),
                                    ),
                                  ],
                                ),
                              ),
                              _DevToggle(
                                value: _mockMode,
                                onChanged: (v) => setState(() => _mockMode = v),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _HintText(
                        'Compile-time default: USE_MOCK_DATA=${AppConfig.useMockData}. '
                        'Runtime override stored in SharedPreferences.',
                      ),
                      const SizedBox(height: 20),

                      // ── Dashboard ─────────────────────────────────────────
                      _sectionLabel('📊  Dashboard'),
                      _ActionButton(
                        label: 'Refresh Dashboard',
                        icon: Icons.refresh_rounded,
                        onTap: _refreshDashboard,
                      ),
                      const SizedBox(height: 20),

                      // ── Quick ref ─────────────────────────────────────────
                      _sectionLabel('ℹ️  Quick Reference'),
                      _Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Ref('Endpoints', 'lib/core/api/endpoints.dart'),
                              _Ref('Models', 'lib/models/*_model.dart'),
                              _Ref('Repository', 'lib/repositories/'),
                              _Ref('Config', 'lib/core/config/app_config.dart'),
                              _Ref('Mock data',
                                  'lib/shared/constants/demo_data.dart'),
                              const SizedBox(height: 4),
                              const Text(
                                'Run with backend:\n'
                                'flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000 \\\n'
                                '  --dart-define=WS_URL=ws://10.0.2.2:8000/ws \\\n'
                                '  --dart-define=USE_MOCK_DATA=false',
                                style: TextStyle(
                                    fontSize: 10.5,
                                    color: GXColors.textMute,
                                    fontFamily: 'monospace',
                                    height: 1.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Save ──────────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _saving ? null : _saveSettings,
                          style: TextButton.styleFrom(
                            backgroundColor: GXColors.violet,
                            foregroundColor: Colors.white,
                            disabledForegroundColor:
                                Colors.white.withValues(alpha: 0.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Save Settings',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: GXColors.textSoft,
              letterSpacing: 0.12),
        ),
      );
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.store});
  final dynamic store;

  @override
  Widget build(BuildContext context) {
    final hasToken = (store.token ?? '').isNotEmpty;
    final isMock = store.mockModeOverride ?? AppConfig.useMockData;
    final userId = store.userId ?? '';

    Color bannerColor;
    String bannerText;

    if (isMock) {
      bannerColor = GXColors.violet;
      bannerText = '🎭  Mock mode active — no network calls.';
    } else if (!hasToken && userId.isEmpty) {
      bannerColor = GXColors.warning;
      bannerText = '⚠️  No token or user ID set. '
          'Paste your Supabase JWT and user UUID to connect.';
    } else if (!hasToken) {
      bannerColor = GXColors.warning;
      bannerText = '⚠️  No bearer token. Auth endpoints will return 401.';
    } else {
      bannerColor = GXColors.success;
      bannerText = '✓  Token and user ID set. Ready to connect.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bannerColor.withValues(alpha: 0.30)),
      ),
      child: Text(bannerText,
          style: TextStyle(fontSize: 12.5, color: bannerColor, height: 1.4)),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: child,
      );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.hint2,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final String? hint2;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: GXColors.textSoft,
                    letterSpacing: 0.10)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              keyboardType: TextInputType.url,
              autocorrect: false,
              style: const TextStyle(
                  fontSize: 13,
                  color: GXColors.textWhite,
                  fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(fontSize: 13, color: GXColors.textMute),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                filled: true,
                fillColor: const Color(0x08FFFFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: GXColors.violet, width: 1.5),
                ),
              ),
            ),
            if (hint2 != null) ...[
              const SizedBox(height: 4),
              Text(hint2!,
                  style: const TextStyle(
                      fontSize: 10.5, color: GXColors.textMute)),
            ],
          ],
        ),
      );
}

class _TokenField extends StatelessWidget {
  const _TokenField({
    required this.controller,
    required this.obscured,
    required this.onToggleObscure,
    required this.savedMasked,
  });

  final TextEditingController controller;
  final bool obscured;
  final VoidCallback onToggleObscure;
  final String savedMasked;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bearer Token',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: GXColors.textSoft,
                    letterSpacing: 0.10)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              obscureText: obscured,
              autocorrect: false,
              enableSuggestions: false,
              style: const TextStyle(
                  fontSize: 13,
                  color: GXColors.textWhite,
                  fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'Paste Supabase JWT here…',
                hintStyle:
                    const TextStyle(fontSize: 13, color: GXColors.textMute),
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(12, 10, 40, 10),
                filled: true,
                fillColor: const Color(0x08FFFFFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: GXColors.violet, width: 1.5),
                ),
                suffixIcon: GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(
                    obscured ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: GXColors.textMute,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Saved: $savedMasked',
                    style: const TextStyle(
                        fontSize: 10.5,
                        color: GXColors.textMute,
                        fontFamily: 'monospace'),
                  ),
                ),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () =>
                        Clipboard.setData(ClipboardData(text: controller.text)),
                    child: const Text('Copy',
                        style: TextStyle(
                            fontSize: 10.5,
                            color: GXColors.violet,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              '⚠️  Never paste Supabase service role keys here — use only user JWTs.',
              style: TextStyle(
                  fontSize: 10.5, color: GXColors.warning, height: 1.4),
            ),
          ],
        ),
      );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.loading = false,
    this.color,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool loading;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? GXColors.violet;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.withValues(alpha: 0.27)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(color: c, strokeWidth: 2),
              )
            else
              Icon(icon, color: c, size: 15),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600, color: c)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text, required this.ok});
  final String text;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final color = ok ? GXColors.success : GXColors.danger;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.27)),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 11.5, color: color, fontFamily: 'monospace', height: 1.5),
      ),
    );
  }
}

class _DevToggle extends StatelessWidget {
  const _DevToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 38,
          height: 22,
          decoration: BoxDecoration(
            color: value ? GXColors.violet : const Color(0x1FFFFFFF),
            borderRadius: BorderRadius.circular(99),
            boxShadow: value
                ? [
                    BoxShadow(
                        color: GXColors.violet.withValues(alpha: 0.40),
                        blurRadius: 12)
                  ]
                : null,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: CircleAvatar(radius: 9, backgroundColor: Colors.white),
            ),
          ),
        ),
      );
}

class _HintText extends StatelessWidget {
  const _HintText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(text,
            style: const TextStyle(
                fontSize: 10.5, color: GXColors.textMute, height: 1.4)),
      );
}

class _Ref extends StatelessWidget {
  const _Ref(this.label, this.path);
  final String label;
  final String path;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 11.5, color: GXColors.textSoft)),
            ),
            Expanded(
              child: Text(path,
                  style: const TextStyle(
                      fontSize: 11.5,
                      color: GXColors.textMute,
                      fontFamily: 'monospace')),
            ),
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: Color(0x12FFFFFF));
}

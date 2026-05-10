import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/gx_colors.dart';
import '../../core/utils/date_helpers.dart';
import '../../models/dashboard_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/user_id_provider.dart';
import '../../shared/widgets/alert_card.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/loading_state.dart';
import 'home_controller.dart';
import 'widgets/demo_trigger_panel.dart';
import 'widgets/mascot_status_card.dart';
import 'widgets/upcoming_bill_card.dart';
import 'widgets/weekly_budget_card.dart';
import '../pockets/widgets/salary_split_animation.dart';
import 'high_risk_modal.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showHighRisk = false;
  bool _showSalary = false;
  OverlayEntry? _toastEntry;

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(homeDashboardProvider);
    final uiState = ref.watch(homeUiProvider);

    return Stack(
      children: [
        RefreshIndicator(
          color: GXColors.violet,
          backgroundColor: const Color(0xFF14053A),
          onRefresh: () => ref.read(homeDashboardProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 60, 18, 130),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildGreeting(),
                    const SizedBox(height: 18),
                    dashAsync.when(
                      loading: () =>
                          const SizedBox(height: 300, child: LoadingState()),
                      error: _buildError,
                      data: (dashboard) => _buildDashboard(dashboard, uiState),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
        // High-risk modal
        if (_showHighRisk)
          HighRiskModal(
            onClose: () => setState(() => _showHighRisk = false),
            onCancel: () {
              setState(() => _showHighRisk = false);
              _showToast('Smart move — transaction cancelled.',
                  color: GXColors.success);
            },
            onContinue: () {
              setState(() => _showHighRisk = false);
              _fireSpend(amount: 100, merchant: 'Shopee', category: 'SHOPPING');
            },
            onRoundUp: () {
              setState(() => _showHighRisk = false);
              // Demo: round-up is a local pocket action — handled by AppState
              ref
                  .read(appStateProvider.notifier)
                  .addToPocket('Emergency Fund', 2);
              _showToast('RM2 rounded up into Emergency Fund 💎',
                  color: GXColors.success);
            },
          ),
        // Salary split animation
        if (_showSalary)
          Builder(builder: (_) {
            final split = ref.read(homeUiProvider).lastSplitResult;
            return SalarySplitAnimation(
              splitLines: split?.lines ?? const [],
              salaryAmount: 1200.0,
              onComplete: () {
                setState(() => _showSalary = false);
                final s = ref.read(homeUiProvider).lastSplitResult;
                // Calculate remaining undo window from the real deadline.
                final remainingSecs = s?.undoDeadline != null
                    ? s!.undoDeadline!
                        .difference(DateTime.now())
                        .inSeconds
                        .clamp(0, 300)
                    : 60;
                _showToastWithUndo(
                  'RM${(s?.totalRouted ?? 420).toStringAsFixed(0)} saved into your GX Pockets.',
                  color: GXColors.violet,
                  initialSeconds: remainingSecs,
                  onUndo: () async {
                    if (s == null) return;
                    final ok = await ref
                        .read(homeDashboardProvider.notifier)
                        .undoAutopilot(s.splitId);
                    ref.read(homeUiProvider.notifier).clearSplitResult();
                    // Refresh pockets after undo
                    ref.invalidate(homeDashboardProvider);
                    _showToast(
                      ok
                          ? 'Salary split undone.'
                          : 'Could not undo. Please try again.',
                      color: ok ? GXColors.warning : GXColors.danger,
                    );
                  },
                );
              },
            );
          }),
      ],
    );
  }

  // ── Dashboard content ─────────────────────────────────────────────────────

  Widget _buildDashboard(DashboardModel d, HomeUiState uiState) {
    final userId = ref.read(resolvedUserIdProvider);

    // Show setup card when no user ID is configured and not in mock mode.
    if (userId == null) return _SetupUserIdCard();

    final budget = dashboardToWeeklyBudget(d);
    final alerts = d.recentAlerts;
    final bills = d.upcomingBills;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mascot
        MascotStatusCard(
          mascotState: d.mascot.state,
          moodLine: d.mascot.moodLine,
          streakDays: d.streakSummary.currentStreak,
        ),
        const SizedBox(height: 14),
        // Budget
        WeeklyBudgetCard(budget: budget),
        const SizedBox(height: 14),
        // Bills
        if (bills.isNotEmpty) ...[
          UpcomingBillCard(bill: bills.first),
          const SizedBox(height: 14),
        ],
        // Active alert
        if (!uiState.alertsDismissed && alerts.isNotEmpty)
          AlertCard(
            alert: alerts.first,
            onAction: alerts.first.actionLabel != null
                ? () {
                    ref.read(homeUiProvider.notifier).dismissAlert();
                    if (alerts.first.targetPocket != null) {
                      ref.read(appStateProvider.notifier).addToPocket(
                            alerts.first.targetPocket!,
                            alerts.first.actionAmount ?? 2,
                          );
                      _showToast(
                        'RM${(alerts.first.actionAmount ?? 2).toStringAsFixed(0)} rounded up into ${alerts.first.targetPocket} 💎',
                        color: GXColors.success,
                      );
                    }
                  }
                : null,
            onDismiss: () => ref.read(homeUiProvider.notifier).dismissAlert(),
          ),
        const SizedBox(height: 18),
        // Demo actions
        const Text(
          'Demo actions',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: GXColors.textWhite,
            letterSpacing: -0.02,
          ),
        ),
        const SizedBox(height: 12),
        DemoTriggerPanel(
          onSpendFood: () =>
              _fireSpend(amount: 50, merchant: 'GrabFood', category: 'FOOD'),
          onSpendShopping: () => setState(() => _showHighRisk = true),
          onReceiveSalary: _fireReceiveSalary,
          onSave: () {
            ref
                .read(appStateProvider.notifier)
                .addToPocket('Emergency Fund', 10);
            _showToast('RM10 saved into Emergency Fund 🎉',
                color: GXColors.success);
          },
        ),
      ],
    );
  }

  Widget _buildError(Object error, StackTrace? _) {
    final isNoUser = error is NoUserIdException;
    return ErrorState(
      message: isNoUser
          ? 'No user ID configured. Enter one below.'
          : 'Could not load dashboard.\n${error.toString()}',
      onRetry: isNoUser
          ? null
          : () => ref.read(homeDashboardProvider.notifier).refresh(),
    );
  }

  // ── Demo action wiring ────────────────────────────────────────────────────

  void _fireSpend({
    required double amount,
    required String merchant,
    required String category,
  }) {
    ref
        .read(homeDashboardProvider.notifier)
        .createTransaction(
          amount: amount,
          merchant: merchant,
          category: category,
        )
        .then((result) {
      if (!mounted) return;
      _showToast('RM${amount.toStringAsFixed(0)} spent on $merchant',
          color: GXColors.pink);
      final alert = result?.alert;
      if (alert != null) {
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) {
            _showToast(alert.message, color: GXColors.warning);
          }
        });
      }
    });
  }

  void _fireReceiveSalary() {
    const salary = 1200.0; // demo salary trigger amount
    ref
        .read(homeDashboardProvider.notifier)
        .receiveSalary(salaryAmount: salary)
        .then((split) {
      if (!mounted) return;
      if (split != null) {
        ref.read(homeUiProvider.notifier).setSplitResult(split);
      }
      setState(() => _showSalary = true);
    });
  }

  // ── Greeting ──────────────────────────────────────────────────────────────

  Widget _buildGreeting() {
    final now = DateTime.now();
    final nameAsync = ref.watch(userNameProvider);
    final name = nameAsync.valueOrNull ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0x0FFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x14FFFFFF)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: GXColors.textWhite, size: 16),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateHelpers.formatDay(now),
                  style:
                      const TextStyle(fontSize: 13, color: GXColors.textSoft),
                ),
                const SizedBox(height: 2),
                Text(
                  name.isNotEmpty ? 'Hi $name 👋' : 'Hi there 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: GXColors.textWhite,
                    letterSpacing: -0.02,
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.push('/notifications'),
          child: Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x0FFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x14FFFFFF)),
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: GXColors.textWhite, size: 18),
              ),
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: GXColors.pink,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: GXColors.pink.withValues(alpha: 0.8),
                          blurRadius: 8)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Toast helpers ─────────────────────────────────────────────────────────

  void _showToast(String msg, {required Color color}) {
    _toastEntry?.remove();
    final entry = OverlayEntry(
      builder: (_) => _Toast(message: msg, color: color),
    );
    _toastEntry = entry;
    Overlay.of(context).insert(entry);
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        entry.remove();
        _toastEntry = null;
      }
    });
  }

  void _showToastWithUndo(
    String msg, {
    required Color color,
    required Future<void> Function() onUndo,
    int initialSeconds = 60,
  }) {
    _toastEntry?.remove();
    Timer? countdown;
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (_) => _UndoToast(
        message: msg,
        color: color,
        initialSeconds: initialSeconds,
        onUndo: () {
          countdown?.cancel();
          entry?.remove();
          onUndo();
        },
      ),
    );
    _toastEntry = entry;
    Overlay.of(context).insert(entry);
    countdown = Timer(Duration(seconds: initialSeconds), () {
      if (mounted) {
        entry?.remove();
        _toastEntry = null;
      }
    });
  }
}

// ─── Setup card for no-user-id state ─────────────────────────────────────────

class _SetupUserIdCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SetupUserIdCard> createState() => _SetupUserIdCardState();
}

class _SetupUserIdCardState extends ConsumerState<_SetupUserIdCard> {
  final _ctrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x1FA855F7), Color(0x05FFFFFF)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x40A855F7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔧  Developer Setup',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: GXColors.textWhite),
            ),
            const SizedBox(height: 6),
            const Text(
              'No user ID is configured. Enter one to load live data from the API, or enable mock mode via --dart-define=USE_MOCK_DATA=true.',
              style: TextStyle(
                  fontSize: 13, color: GXColors.textSoft, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              style: const TextStyle(color: GXColors.textWhite, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Paste Supabase user UUID here…',
                hintStyle:
                    const TextStyle(color: GXColors.textMute, fontSize: 13.5),
                filled: true,
                fillColor: const Color(0x0DFFFFFF),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0x27FFFFFF), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0x27FFFFFF), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: GXColors.violet, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _saving
                    ? null
                    : () async {
                        final id = _ctrl.text.trim();
                        if (id.isEmpty) return;
                        setState(() => _saving = true);
                        await ref.read(authTokenStoreProvider).setUserId(id);
                        if (!mounted) return;
                        ref.invalidate(homeDashboardProvider);
                        setState(() => _saving = false);
                      },
                style: TextButton.styleFrom(
                  backgroundColor: GXColors.violet,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Connect',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ],
        ),
      );
}

// ─── Toast widgets ────────────────────────────────────────────────────────────

class _Toast extends StatelessWidget {
  const _Toast({required this.message, required this.color});
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) => Positioned(
        left: 16,
        right: 16,
        bottom: 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xF214053A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.40)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5), blurRadius: 40),
                BoxShadow(color: color.withValues(alpha: 0.20), blurRadius: 40),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: color, blurRadius: 12)],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(message,
                        style: const TextStyle(
                            fontSize: 13.5, color: GXColors.textWhite))),
              ],
            ),
          ),
        ),
      );
}

class _UndoToast extends StatefulWidget {
  const _UndoToast({
    required this.message,
    required this.color,
    required this.onUndo,
    this.initialSeconds = 60,
  });
  final String message;
  final Color color;
  final VoidCallback onUndo;

  /// Countdown start value, computed from the server's undo_deadline.
  final int initialSeconds;

  @override
  State<_UndoToast> createState() => _UndoToastState();
}

class _UndoToastState extends State<_UndoToast> {
  late Timer _timer;
  late int _secs;

  @override
  void initState() {
    super.initState();
    _secs = widget.initialSeconds.clamp(0, 300);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _secs--;
        if (_secs <= 0) _timer.cancel();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Positioned(
        left: 16,
        right: 16,
        bottom: 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xF214053A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.color.withValues(alpha: 0.40)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5), blurRadius: 40),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: widget.color, blurRadius: 12)],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(widget.message,
                        style: const TextStyle(
                            fontSize: 13.5, color: GXColors.textWhite))),
                if (_secs > 0) ...[
                  Text('${_secs}s ',
                      style: const TextStyle(
                          fontSize: 12, color: GXColors.textMute)),
                  GestureDetector(
                    onTap: widget.onUndo,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0x14FFFFFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x1FFFFFFF)),
                      ),
                      child: const Text('Undo',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: GXColors.textWhite)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

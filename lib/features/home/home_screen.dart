import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/gx_colors.dart';
import '../../core/utils/date_helpers.dart';
import '../../shared/constants/demo_data.dart';
import '../../shared/widgets/alert_card.dart';
import '../../features/notifications/notification_preview_screen.dart';
import 'home_controller.dart';
import 'widgets/mascot_status_card.dart';
import 'widgets/weekly_budget_card.dart';
import 'widgets/upcoming_bill_card.dart';
import 'widgets/demo_trigger_panel.dart';
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
    final state = ref.watch(appStateProvider);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 60, 18, 130),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Greeting
                  _buildGreeting(),
                  const SizedBox(height: 18),
                  // Mascot
                  MascotStatusCard(
                    mascotState: state.mascotState,
                    streakDays: state.streakDays,
                  ),
                  const SizedBox(height: 14),
                  // Budget
                  WeeklyBudgetCard(budget: state.budget),
                  const SizedBox(height: 14),
                  // Bill
                  ...DemoData.upcomingBills.take(1).map(
                        (b) => UpcomingBillCard(bill: b),
                      ),
                  const SizedBox(height: 14),
                  // Active alert
                  if (!state.alertsDismissed && DemoData.activeAlerts.isNotEmpty)
                    AlertCard(
                      alert: DemoData.activeAlerts.first,
                      onAction: () {
                        ref.read(appStateProvider.notifier).addToPocket('Emergency Fund', 2);
                        ref.read(appStateProvider.notifier).dismissAlert();
                        _showToast('RM2 rounded up into Emergency Fund 💎',
                            color: GXColors.success);
                      },
                      onDismiss: () =>
                          ref.read(appStateProvider.notifier).dismissAlert(),
                    ),
                  const SizedBox(height: 18),
                  // Demo triggers
                  const Text(
                    'Demo actions',
                    style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700,
                      color: GXColors.textWhite, letterSpacing: -0.02,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DemoTriggerPanel(
                    onSpendFood: () {
                      ref.read(appStateProvider.notifier).spendFood(50);
                      _showToast('RM50 spent on food 👀', color: GXColors.pink);
                    },
                    onSpendShopping: () => setState(() => _showHighRisk = true),
                    onReceiveSalary: () {
                      ref.read(appStateProvider.notifier).receiveSalary();
                      setState(() => _showSalary = true);
                    },
                    onSave: () {
                      ref.read(appStateProvider.notifier).addToPocket('Emergency Fund', 10);
                      _showToast('RM10 saved into Emergency Fund 🎉',
                          color: GXColors.success);
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
        // High-risk modal
        if (_showHighRisk)
          HighRiskModal(
            onClose: () => setState(() => _showHighRisk = false),
            onCancel: () {
              setState(() => _showHighRisk = false);
              ref.read(appStateProvider.notifier).setCalm();
              _showToast('Smart move — transaction cancelled.', color: GXColors.success);
            },
            onContinue: () {
              setState(() => _showHighRisk = false);
              ref.read(appStateProvider.notifier).spendShopping(100);
              _showToast('Pushed past your weekly limit 😬', color: GXColors.danger);
            },
            onRoundUp: () {
              setState(() => _showHighRisk = false);
              ref.read(appStateProvider.notifier).addToPocket('Emergency Fund', 2);
              _showToast('RM2 rounded up into Emergency Fund 💎', color: GXColors.success);
            },
          ),
        // Salary animation
        if (_showSalary)
          SalarySplitAnimation(
            onComplete: () {
              setState(() => _showSalary = false);
              _showToastWithUndo(
                'RM420 saved into your GX Pockets.',
                color: GXColors.violet,
                onUndo: () {
                  ref.read(appStateProvider.notifier).undoSalarySplit();
                  _showToast('Salary split undone.', color: GXColors.warning);
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildGreeting() {
    final now = DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateHelpers.formatDay(now),
              style: const TextStyle(fontSize: 13, color: GXColors.textSoft),
            ),
            const SizedBox(height: 2),
            const Text(
              'Hi Aiman 👋',
              style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700,
                color: GXColors.textWhite, letterSpacing: -0.02,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.of(context, rootNavigator: true)
              .push(MaterialPageRoute(builder: (_) => const NotificationPreviewScreen())),
          child: Stack(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0x0FFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x14FFFFFF)),
                ),
                child: const Icon(Icons.notifications_outlined, color: GXColors.textWhite, size: 18),
              ),
              Positioned(
                top: 8, right: 9,
                child: Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: GXColors.pink,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: GXColors.pink.withValues(alpha: 0.8), blurRadius: 8)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showToast(String msg, {required Color color}) {
    _toastEntry?.remove();
    final entry = OverlayEntry(
      builder: (_) => _Toast(message: msg, color: color),
    );
    _toastEntry = entry;
    Overlay.of(context).insert(entry);
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) { entry.remove(); _toastEntry = null; }
    });
  }

  void _showToastWithUndo(String msg, {required Color color, required VoidCallback onUndo}) {
    _toastEntry?.remove();
    Timer? countdown;
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (_) => _UndoToast(
        message: msg,
        color: color,
        onUndo: () {
          countdown?.cancel();
          entry?.remove();
          onUndo();
        },
      ),
    );
    _toastEntry = entry;
    Overlay.of(context).insert(entry);
    countdown = Timer(const Duration(seconds: 60), () {
      if (mounted) { entry?.remove(); _toastEntry = null; }
    });
  }
}

// ── Toast widgets ─────────────────────────────────────────────────────────────

class _Toast extends StatelessWidget {
  const _Toast({required this.message, required this.color});
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) => Positioned(
        left: 16, right: 16, bottom: 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xF214053A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.40)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40),
                BoxShadow(color: color.withValues(alpha: 0.20), blurRadius: 40),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: color, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: color, blurRadius: 12)],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(message, style: const TextStyle(fontSize: 13.5, color: GXColors.textWhite))),
              ],
            ),
          ),
        ),
      );
}

class _UndoToast extends StatefulWidget {
  const _UndoToast({required this.message, required this.color, required this.onUndo});
  final String message;
  final Color color;
  final VoidCallback onUndo;

  @override
  State<_UndoToast> createState() => _UndoToastState();
}

class _UndoToastState extends State<_UndoToast> {
  late Timer _timer;
  int _secs = 60;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() { _secs--; if (_secs <= 0) _timer.cancel(); });
    });
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Positioned(
        left: 16, right: 16, bottom: 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xF214053A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: widget.color.withValues(alpha: 0.40)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40)],
            ),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: widget.color, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: widget.color, blurRadius: 12)],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(widget.message, style: const TextStyle(fontSize: 13.5, color: GXColors.textWhite))),
                Text('${_secs}s ', style: const TextStyle(fontSize: 12, color: GXColors.textMute)),
                GestureDetector(
                  onTap: widget.onUndo,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0x14FFFFFF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x1FFFFFFF)),
                    ),
                    child: const Text('Undo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GXColors.textWhite)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

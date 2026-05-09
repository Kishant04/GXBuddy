import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/gx_colors.dart';
import '../../models/squad_model.dart';
import '../../providers/websocket_provider.dart';
import '../../shared/widgets/budget_progress_bar.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/gx_button.dart';
import '../../shared/widgets/gx_card.dart';
import '../../shared/widgets/loading_state.dart';
import 'squad_controller.dart';
import 'widgets/invite_friends_sheet.dart';
import 'widgets/streak_shield_modal.dart';

class SquadScreen extends ConsumerStatefulWidget {
  const SquadScreen({super.key});

  @override
  ConsumerState<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends ConsumerState<SquadScreen> {
  bool _showShield = false;
  SquadMember? _shieldTarget;
  String? _toastMsg;

  void _toast(String msg) {
    setState(() => _toastMsg = msg);
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) setState(() => _toastMsg = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final squadAsync = ref.watch(squadNotifierProvider);

    // React to WebSocket streak_shield events
    ref.listen(wsStreakShieldEventProvider, (_, event) {
      if (event != null && mounted) {
        final squad = ref.read(squadNotifierProvider).valueOrNull;
        final idx = event.memberIndex;
        final target = idx != null
            ? squad?.members
                .where((m) => m.parsedMemberIndex == idx)
                .firstOrNull
            : null;
        setState(() {
          _shieldTarget = target;
          _showShield = true;
        });
        ref.read(wsStreakShieldEventProvider.notifier).state = null;
      }
    });

    return Stack(
      children: [
        RefreshIndicator(
          color: GXColors.violet,
          backgroundColor: const Color(0xFF14053A),
          onRefresh: () => ref.read(squadNotifierProvider.notifier).refresh(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 60, 18, 130),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    squadAsync.when(
                      loading: () =>
                          const SizedBox(height: 300, child: LoadingState()),
                      error: (e, _) => ErrorState(
                        message: 'Could not load squad.',
                        onRetry: () =>
                            ref.read(squadNotifierProvider.notifier).refresh(),
                      ),
                      data: (squad) => squad == null
                          ? _NoSquadView()
                          : _SquadView(
                              squad: squad,
                              onShield: (member) {
                                setState(() {
                                  _shieldTarget = member;
                                  _showShield = true;
                                });
                              },
                              onToast: _toast,
                            ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
        // Shield modal
        if (_showShield)
          StreakShieldModal(
            targetMember: _shieldTarget,
            onSend: () async {
              setState(() => _showShield = false);
              final idx = _shieldTarget?.parsedMemberIndex;
              if (idx == null) {
                _toast('Could not send rally — unknown member.');
                return;
              }
              final ok =
                  await ref.read(squadNotifierProvider.notifier).sendRally(idx);
              _toast(ok
                  ? 'Hold Strong sent to ${_shieldTarget?.displayName ?? 'teammate'} 💪'
                  : 'Failed to send rally. Please try again.');
            },
            onSoftBlock: () {
              setState(() => _showShield = false);
              _toast('Soft block requested.');
            },
            onIgnore: () => setState(() => _showShield = false),
          ),
        // Toast
        if (_toastMsg != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 100,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xF214053A),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: GXColors.violet.withValues(alpha: 0.40)),
                  boxShadow: const [
                    BoxShadow(color: Color(0x80000000), blurRadius: 40)
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: GXColors.violet, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(_toastMsg!,
                            style: const TextStyle(
                                fontSize: 13.5, color: GXColors.textWhite))),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── No-squad state ────────────────────────────────────────────────────────────

class _NoSquadView extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NoSquadView> createState() => _NoSquadViewState();
}

class _NoSquadViewState extends ConsumerState<_NoSquadView> {
  final _joinCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  bool _showCreate = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _joinCtrl.dispose();
    _nameCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your squad',
            style: TextStyle(fontSize: 13, color: GXColors.textSoft)),
        const SizedBox(height: 2),
        const Text('No squad yet',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: GXColors.textWhite,
                letterSpacing: -0.02)),
        const SizedBox(height: 24),
        GXCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🤝  Join or create a squad',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: GXColors.textWhite)),
              const SizedBox(height: 6),
              const Text(
                'Save together with friends. Only progress % is visible — balances stay private.',
                style: TextStyle(
                    fontSize: 13, color: GXColors.textSoft, height: 1.4),
              ),
              const SizedBox(height: 20),
              // Join
              const Text('HAVE AN INVITE CODE?',
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: GXColors.textSoft,
                      letterSpacing: 0.14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _joinCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(
                          color: GXColors.textWhite, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'GXBUDDY-XXXXXX',
                        hintStyle: const TextStyle(
                            color: GXColors.textMute, fontSize: 13.5),
                        filled: true,
                        fillColor: const Color(0x0DFFFFFF),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0x27FFFFFF)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0x27FFFFFF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: GXColors.violet, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GXButton(
                    label: 'Join',
                    onPressed: _loading ? null : _joinSquad,
                    variant: GXButtonVariant.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: GXColors.border, height: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('or',
                        style:
                            TextStyle(fontSize: 12, color: GXColors.textMute)),
                  ),
                  Expanded(child: Divider(color: GXColors.border, height: 1)),
                ],
              ),
              const SizedBox(height: 16),
              // Create
              if (!_showCreate)
                GXButton(
                  label: '+ Create a new squad',
                  onPressed: () => setState(() => _showCreate = true),
                  variant: GXButtonVariant.soft,
                  expand: true,
                )
              else
                _CreateSquadForm(
                  nameCtrl: _nameCtrl,
                  goalCtrl: _goalCtrl,
                  onSubmit: _createSquad,
                  loading: _loading,
                ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style:
                        const TextStyle(fontSize: 12, color: GXColors.danger)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _joinSquad() async {
    final code = _joinCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final id = await ref.read(squadNotifierProvider.notifier).joinSquad(code);
    if (!mounted) return;
    setState(() => _loading = false);
    if (id == null) {
      setState(() => _error = 'Invalid invite code. Please try again.');
    }
  }

  Future<void> _createSquad() async {
    final name = _nameCtrl.text.trim();
    final goalText = _goalCtrl.text.trim();
    if (name.isEmpty || goalText.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    final goal = double.tryParse(goalText);
    if (goal == null || goal <= 0) {
      setState(() => _error = 'Enter a valid goal amount.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final id = await ref.read(squadNotifierProvider.notifier).createSquad(
          name: name,
          goalName: 'Save RM${goal.toStringAsFixed(0)} together',
          goalAmount: goal,
          deadline: DateTime.now().add(const Duration(days: 30)),
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (id == null) {
      setState(() => _error = 'Could not create squad. Please try again.');
    }
  }
}

class _CreateSquadForm extends StatelessWidget {
  const _CreateSquadForm({
    required this.nameCtrl,
    required this.goalCtrl,
    required this.onSubmit,
    required this.loading,
  });
  final TextEditingController nameCtrl;
  final TextEditingController goalCtrl;
  final VoidCallback onSubmit;
  final bool loading;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SQUAD NAME',
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: GXColors.textSoft,
                  letterSpacing: 0.14)),
          const SizedBox(height: 6),
          _field(nameCtrl, 'e.g. Broke No More Squad'),
          const SizedBox(height: 12),
          const Text('SAVINGS GOAL (RM)',
              style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: GXColors.textSoft,
                  letterSpacing: 0.14)),
          const SizedBox(height: 6),
          _field(goalCtrl, 'e.g. 500', keyboardType: TextInputType.number),
          const SizedBox(height: 14),
          GXButton(
            label: loading ? 'Creating…' : 'Create Squad',
            onPressed: loading ? null : onSubmit,
            variant: GXButtonVariant.primary,
            expand: true,
          ),
        ],
      );

  Widget _field(TextEditingController ctrl, String hint,
          {TextInputType? keyboardType}) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(color: GXColors.textWhite, fontSize: 13.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: GXColors.textMute, fontSize: 13.5),
          filled: true,
          fillColor: const Color(0x0DFFFFFF),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0x27FFFFFF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0x27FFFFFF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: GXColors.violet, width: 1.5),
          ),
        ),
      );
}

// ── Squad content ─────────────────────────────────────────────────────────────

class _SquadView extends ConsumerWidget {
  const _SquadView({
    required this.squad,
    required this.onShield,
    required this.onToast,
  });
  final SquadModel squad;
  final void Function(SquadMember? member) onShield;
  final void Function(String msg) onToast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nudgeMember = squad.members.where((m) => m.needsNudge).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your squad',
                      style: TextStyle(fontSize: 13, color: GXColors.textSoft)),
                  const SizedBox(height: 2),
                  Text(
                    squad.name,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: GXColors.textWhite,
                        letterSpacing: -0.02),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0x0FFFFFFF),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: const Color(0x1AFFFFFF)),
              ),
              child: Text('${squad.members.length} members',
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: GXColors.textWhite)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _GoalCard(squad: squad),
        const SizedBox(height: 14),
        _InsightCard(
          insight: squad.weeklyInsight,
          onShield: () => onShield(nudgeMember),
          onInvite: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => InviteFriendsSheet(squad: squad),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Members',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: GXColors.textWhite,
                letterSpacing: -0.02)),
        const SizedBox(height: 12),
        ...squad.members.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MemberCard(member: m),
            )),
        const SizedBox(height: 14),
        _RewardCard(description: squad.rewardDescription),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.squad});
  final SquadModel squad;

  @override
  Widget build(BuildContext context) => GXCard(
        padding: const EdgeInsets.all(18),
        glowColor: GXColors.pink,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GXColors.pink.withValues(alpha: 0.13),
            const Color(0x05FFFFFF)
          ],
        ),
        accentBorderColor: GXColors.pink.withValues(alpha: 0.27),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SHARED GOAL',
                          style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFF8FB1),
                              letterSpacing: 0.1,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(squad.goalDescription,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: GXColors.textWhite)),
                    ],
                  ),
                ),
                Text(
                  '${squad.progressPercent.toInt()}%',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: GXColors.textWhite,
                      letterSpacing: -0.025),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BudgetProgressBar(
                value: squad.progressPercent,
                max: 100,
                height: 9,
                showThresholds: false,
                color: GXColors.pink),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'RM${squad.savedAmount.toStringAsFixed(0)} of RM${squad.goalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 11, color: GXColors.textSoft)),
                Text('${squad.daysLeft} days left',
                    style: const TextStyle(
                        fontSize: 11, color: GXColors.textSoft)),
              ],
            ),
          ],
        ),
      );
}

class _InsightCard extends StatelessWidget {
  const _InsightCard(
      {required this.insight, required this.onShield, required this.onInvite});
  final String insight;
  final VoidCallback onShield;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) => GXCard(
        padding: const EdgeInsets.all(14),
        glowColor: GXColors.violet,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GXColors.violet.withValues(alpha: 0.10),
            const Color(0x05FFFFFF)
          ],
        ),
        accentBorderColor: GXColors.violet.withValues(alpha: 0.33),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🤖', style: TextStyle(fontSize: 13)),
                SizedBox(width: 8),
                Text('WEEKLY SQUAD INSIGHT',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC9A8FF),
                        letterSpacing: 0.1)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              insight.isEmpty
                  ? 'Keep it up! Your squad is making great progress.'
                  : insight,
              style: const TextStyle(
                  fontSize: 13.5, color: GXColors.textWhite, height: 1.45),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                GXButton(
                  label: 'Send Hold Strong 💪',
                  onPressed: onShield,
                  variant: GXButtonVariant.primary,
                  size: GXButtonSize.sm,
                ),
                const SizedBox(width: 8),
                GXButton(
                  label: 'Invite Friends',
                  onPressed: onInvite,
                  variant: GXButtonVariant.ghost,
                  size: GXButtonSize.sm,
                ),
              ],
            ),
          ],
        ),
      );
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});
  final SquadMember member;

  @override
  Widget build(BuildContext context) => GXCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [member.color, member.color.withValues(alpha: 0.67)],
                ),
                border: Border.all(
                    color: member.color.withValues(alpha: 0.33), width: 2),
              ),
              child: Center(
                child: Text(member.initials,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: GXColors.textWhite)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(member.displayName,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: GXColors.textWhite)),
                          if (member.isYou)
                            const Text(' · you',
                                style: TextStyle(
                                    fontSize: 10, color: GXColors.textMute)),
                        ],
                      ),
                      Text(
                        '${member.progressPercent.toInt()}%',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: GXColors.textWhite),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  BudgetProgressBar(
                    value: member.progressPercent,
                    max: 100,
                    height: 4,
                    showThresholds: false,
                    color: member.color,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('🔥 ${member.streakDays}-day streak',
                          style: const TextStyle(
                              fontSize: 11, color: GXColors.textMute)),
                      Text(
                        member.status,
                        style: TextStyle(
                          fontSize: 11,
                          color: member.needsNudge
                              ? GXColors.warning
                              : GXColors.textMute,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.description});
  final String description;

  @override
  Widget build(BuildContext context) => GXCard(
        padding: const EdgeInsets.all(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x387C3AED), Color(0x38F8326D)],
        ),
        accentBorderColor: const Color(0x66A855F7),
        child: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hit a 30-day streak',
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: GXColors.textWhite)),
                  Text(
                    description.isEmpty
                        ? 'Unlock vouchers & GX rewards'
                        : description,
                    style: const TextStyle(
                        fontSize: 11.5, color: GXColors.textSoft),
                  ),
                ],
              ),
            ),
            const Text('+200 pts',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: GXColors.gold)),
          ],
        ),
      );
}

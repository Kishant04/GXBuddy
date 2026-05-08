import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/gx_colors.dart';
import '../../shared/widgets/gx_card.dart';
import '../../shared/widgets/gx_button.dart';
import '../../shared/widgets/budget_progress_bar.dart';
import '../../models/squad.dart';
import '../../models/squad_member.dart';
import 'squad_controller.dart';
import 'widgets/streak_shield_modal.dart';
import 'widgets/invite_friends_sheet.dart';

class SquadScreen extends ConsumerStatefulWidget {
  const SquadScreen({super.key});

  @override
  ConsumerState<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends ConsumerState<SquadScreen> {
  bool _showShield = false;
  String? _toastMsg;

  void _toast(String msg) {
    setState(() => _toastMsg = msg);
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) setState(() => _toastMsg = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final squad = ref.watch(squadProvider);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 60, 18, 130),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Your squad', style: TextStyle(fontSize: 13, color: GXColors.textSoft)),
                            const SizedBox(height: 2),
                            Text(
                              squad.name,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: GXColors.textWhite, letterSpacing: -0.02),
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
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: GXColors.textWhite)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Goal card
                  _GoalCard(squad: squad),
                  const SizedBox(height: 14),
                  // AI insight
                  _InsightCard(
                    insight: squad.weeklyInsight,
                    onShield: () => setState(() => _showShield = true),
                    onInvite: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const InviteFriendsSheet(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Members',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: GXColors.textWhite, letterSpacing: -0.02)),
                  const SizedBox(height: 12),
                  ...squad.members.map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _MemberCard(member: m),
                      )),
                  const SizedBox(height: 14),
                  _RewardCard(description: squad.rewardDescription),
                ]),
              ),
            ),
          ],
        ),
        // Shield modal
        if (_showShield)
          StreakShieldModal(
            onSend: () {
              setState(() => _showShield = false);
              _toast('Hold Strong sent to Kumar 💪');
            },
            onSoftBlock: () {
              setState(() => _showShield = false);
              _toast('Soft block requested. Kumar will be asked to confirm.');
            },
            onIgnore: () => setState(() => _showShield = false),
          ),
        // Toast
        if (_toastMsg != null)
          Positioned(
            left: 16, right: 16, bottom: 100,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xF214053A),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: GXColors.violet.withValues(alpha: 0.40)),
                  boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 40)],
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: GXColors.violet, shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_toastMsg!, style: const TextStyle(fontSize: 13.5, color: GXColors.textWhite))),
                  ],
                ),
              ),
            ),
          ),
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
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [GXColors.pink.withValues(alpha: 0.13), const Color(0x05FFFFFF)],
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
                          style: TextStyle(fontSize: 11, color: Color(0xFFFF8FB1), letterSpacing: 0.1, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(squad.goalDescription,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: GXColors.textWhite)),
                    ],
                  ),
                ),
                Text(
                  '${squad.progressPercent.toInt()}%',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: GXColors.textWhite, letterSpacing: -0.025),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BudgetProgressBar(value: squad.progressPercent, max: 100, height: 9, showThresholds: false, color: GXColors.pink),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('RM${squad.savedAmount.toStringAsFixed(0)} of RM${squad.goalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 11, color: GXColors.textSoft)),
                Text('${squad.daysLeft} days left',
                    style: const TextStyle(fontSize: 11, color: GXColors.textSoft)),
              ],
            ),
          ],
        ),
      );
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight, required this.onShield, required this.onInvite});
  final String insight;
  final VoidCallback onShield;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) => GXCard(
        padding: const EdgeInsets.all(14),
        glowColor: GXColors.violet,
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [GXColors.violet.withValues(alpha: 0.10), const Color(0x05FFFFFF)],
        ),
        accentBorderColor: GXColors.violet.withValues(alpha: 0.33),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Text('🤖', style: TextStyle(fontSize: 13)),
                SizedBox(width: 8),
                Text('WEEKLY SQUAD INSIGHT',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFC9A8FF), letterSpacing: 0.1)),
              ],
            ),
            const SizedBox(height: 6),
            Text(insight, style: const TextStyle(fontSize: 13.5, color: GXColors.textWhite, height: 1.45)),
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
              width: 42, height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [member.color, member.color.withValues(alpha: 0.67)],
                ),
                border: Border.all(color: member.color.withValues(alpha: 0.33), width: 2),
              ),
              child: Center(
                child: Text(member.initials,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GXColors.textWhite)),
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
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: GXColors.textWhite)),
                          if (member.isYou)
                            const Text(' · you', style: TextStyle(fontSize: 10, color: GXColors.textMute)),
                        ],
                      ),
                      Text(
                        '${member.progressPercent.toInt()}%',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: GXColors.textWhite),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  BudgetProgressBar(
                    value: member.progressPercent, max: 100, height: 4,
                    showThresholds: false, color: member.color,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('🔥 ${member.streakDays}-day streak',
                          style: const TextStyle(fontSize: 11, color: GXColors.textMute)),
                      Text(
                        member.status,
                        style: TextStyle(
                          fontSize: 11, color: member.needsNudge ? GXColors.warning : GXColors.textMute,
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
          begin: Alignment.topLeft, end: Alignment.bottomRight,
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
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: GXColors.textWhite)),
                  Text(description.isEmpty ? 'Unlock vouchers & GX rewards' : description,
                      style: const TextStyle(fontSize: 11.5, color: GXColors.textSoft)),
                ],
              ),
            ),
            const Text('+200 pts',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GXColors.gold)),
          ],
        ),
      );
}

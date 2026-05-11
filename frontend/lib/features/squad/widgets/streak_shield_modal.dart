import 'package:flutter/material.dart';
import '../../../core/theme/gx_colors.dart';
import '../../../models/squad_model.dart';
import '../../../shared/widgets/gx_button.dart';

class StreakShieldModal extends StatefulWidget {
  const StreakShieldModal({
    super.key,
    required this.onSend,
    required this.onSoftBlock,
    required this.onIgnore,
    this.targetMember,
  });

  final VoidCallback onSend;
  final VoidCallback onSoftBlock;
  final VoidCallback onIgnore;

  /// The member who triggered the streak shield. When null a generic message
  /// is shown (e.g. when triggered by a WebSocket event with no member data).
  final SquadMember? targetMember;

  @override
  State<StreakShieldModal> createState() => _StreakShieldModalState();
}

class _StreakShieldModalState extends State<StreakShieldModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _slide = Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Cubic(0.16, 0.84, 0.32, 1)),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  SquadMember? get _member => widget.targetMember;
  String get _memberName => _member?.displayName ?? 'a teammate';
  String get _initials => _member?.initials ?? '?';
  Color get _memberColor => _member?.color ?? GXColors.pink;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: widget.onIgnore,
        child: Container(
          color: Colors.black.withValues(alpha: 0.60),
          child: GestureDetector(
            onTap: () {},
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: _slide,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1F0A4D),
                        Color(0xFF0E0228),
                        Color(0xFF08001A)
                      ],
                      stops: [0.0, 0.75, 1.0],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border.all(
                        color: GXColors.violet.withValues(alpha: 0.53)),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0xB3000000),
                          blurRadius: 80,
                          offset: Offset(0, -30))
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(
                      20, 18, 20, MediaQuery.of(context).padding.bottom + 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: const Color(0x30FFFFFF),
                            borderRadius: BorderRadius.circular(99)),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                              colors: [GXColors.violet, GXColors.pink]),
                          boxShadow: [
                            BoxShadow(
                                color: GXColors.violet.withValues(alpha: 0.55),
                                blurRadius: 36)
                          ],
                        ),
                        child: const Center(
                            child: Text('🛡️', style: TextStyle(fontSize: 42))),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '· STREAK SHIELD TRIGGERED ·',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD6BFFF),
                            letterSpacing: 0.18),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$_memberName needs backup',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: GXColors.textWhite,
                            letterSpacing: -0.03),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "They're one purchase away from breaking the squad's streak. Rally for them?",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13,
                              color: GXColors.textSoft,
                              height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Member card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0x0AFFFFFF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x14FFFFFF)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: [
                                  _memberColor,
                                  _memberColor.withValues(alpha: 0.7)
                                ]),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          _memberColor.withValues(alpha: 0.33),
                                      blurRadius: 12)
                                ],
                              ),
                              child: Center(
                                child: Text(_initials,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: GXColors.textWhite)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _member != null
                                        ? '$_memberName · ${_member!.progressPercent.toInt()}% to goal'
                                        : _memberName,
                                    style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: GXColors.textWhite),
                                  ),
                                  if (_member != null)
                                    Text(
                                      '🔥 ${_member!.streakDays}-day streak',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: GXColors.textSoft),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0x2DEF4444),
                                borderRadius: BorderRadius.circular(99),
                                border:
                                    Border.all(color: const Color(0x66EF4444)),
                              ),
                              child: const Text('AT RISK',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFFF9999),
                                      letterSpacing: 0.06)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Privacy-safe — teammates never see balances, only %',
                        style: TextStyle(
                            fontSize: 10.5,
                            color: GXColors.textMute,
                            letterSpacing: 0.04),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      GXButton(
                        label: '💪  Send "Hold Strong"',
                        onPressed: widget.onSend,
                        variant: GXButtonVariant.primary,
                        size: GXButtonSize.lg,
                        expand: true,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GXButton(
                              label: 'Soft Block',
                              onPressed: widget.onSoftBlock,
                              variant: GXButtonVariant.soft,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GXButton(
                              label: 'Ignore',
                              onPressed: widget.onIgnore,
                              variant: GXButtonVariant.ghost,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

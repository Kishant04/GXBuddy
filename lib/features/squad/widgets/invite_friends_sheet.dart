import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/gx_colors.dart';
import '../../../shared/widgets/gx_button.dart';

class InviteFriendsSheet extends StatelessWidget {
  const InviteFriendsSheet({super.key});

  static const _code = 'GXBUDDY-BRKNOMORE';

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF1F0A4D), Color(0xFF0E0228), Color(0xFF08001A)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(context).padding.bottom + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0x30FFFFFF), borderRadius: BorderRadius.circular(99)),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Invite to squad', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: GXColors.textWhite, letterSpacing: -0.03)),
            const SizedBox(height: 4),
            const Text('Grow stronger together. Up to 5 members per squad.', style: TextStyle(fontSize: 13, color: GXColors.textSoft)),
            const SizedBox(height: 20),
            // Invite code
            const Text('INVITE CODE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: GXColors.textSoft, letterSpacing: 0.14)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: _code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invite code copied!')),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GXColors.violet.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: GXColors.violet.withValues(alpha: 0.27)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _code,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GXColors.textWhite, letterSpacing: 0.06),
                      ),
                    ),
                    const Icon(Icons.copy_rounded, color: GXColors.textSoft, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Friend slots
            const Text('FRIEND SLOTS', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: GXColors.textSoft, letterSpacing: 0.14)),
            const SizedBox(height: 8),
            ...['Aiman (You)', 'Mei', 'Kumar', 'Sarah'].asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FriendSlot(name: e.value, index: e.key),
            )),
            _FriendSlot(name: 'Empty slot', index: 4, empty: true),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GXColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: GXColors.success.withValues(alpha: 0.20)),
              ),
              child: const Row(
                children: [
                  Text('🔒', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your friends only see progress %, not your exact balance.',
                      style: TextStyle(fontSize: 12, color: GXColors.textSoft, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GXButton(
                    label: 'Copy Invite Code',
                    onPressed: () {
                      Clipboard.setData(const ClipboardData(text: _code));
                      Navigator.of(context).pop();
                    },
                    variant: GXButtonVariant.soft,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GXButton(
                    label: 'Send Invite',
                    onPressed: () => Navigator.of(context).pop(),
                    variant: GXButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _FriendSlot extends StatelessWidget {
  const _FriendSlot({required this.name, required this.index, this.empty = false});
  final String name;
  final int index;
  final bool empty;

  static const _colors = [
    Color(0xFFA855F7), Color(0xFF1FB287), Color(0xFFF8326D), Color(0xFF3B82F6), Color(0xFF6B7280),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x08FFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: empty ? const Color(0x0FFFFFFF) : color.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: empty ? const Color(0x0FFFFFFF) : color.withValues(alpha: 0.20),
              border: Border.all(color: empty ? const Color(0x1AFFFFFF) : color.withValues(alpha: 0.40)),
            ),
            child: Center(
              child: Text(
                empty ? '+' : name[0],
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: empty ? GXColors.textMute : color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            name,
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: empty ? GXColors.textMute : GXColors.textWhite,
            ),
          ),
          const Spacer(),
          if (!empty && index == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: GXColors.violet.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: GXColors.violet.withValues(alpha: 0.27)),
              ),
              child: const Text('You', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: GXColors.violet)),
            ),
        ],
      ),
    );
  }
}

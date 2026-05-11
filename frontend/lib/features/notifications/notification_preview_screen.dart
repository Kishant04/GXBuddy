import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/gx_colors.dart';
import '../../shared/widgets/gx_card.dart';

class NotificationPreviewScreen extends StatelessWidget {
  const NotificationPreviewScreen({super.key});

  static const _notifications = [
    _NotifItem('📊', 'Budget Alert', "You're at 80% of your food budget.",
        'warning', 'Just now'),
    _NotifItem('📱', 'Bill Reminder', 'Phone bill due in 2 days.', 'info',
        '5 min ago'),
    _NotifItem('🛡️', 'Streak Shield', 'Kumar needs a Hold Strong nudge.',
        'shield', '1 hour ago'),
    _NotifItem(
        '💸',
        'Autopilot',
        'Salary detected. RM420 saved into GX Pockets.',
        'success',
        '2 days ago'),
    _NotifItem('👀', 'Pattern Spotted', 'Third GrabFood order this week.',
        'warning', 'Mon 8:42pm'),
    _NotifItem('🎉', 'Streak!', 'You hit an 8-day saving streak. Keep going!',
        'success', 'Sun 9:00am'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
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
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                title: const Text('Notification Previews',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: GXColors.textWhite)),
                leading: IconButton(
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0x0FFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x1AFFFFFF)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: GXColors.textWhite),
                  ),
                  onPressed: () => context.go('/bank'),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      'How GXBuddy reaches you',
                      style: TextStyle(
                          fontSize: 13, color: GXColors.textSoft, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    // Channel badges
                    Row(
                      children: const [
                        _ChannelBadge(
                            icon: '📲', label: 'Push', color: GXColors.violet),
                        SizedBox(width: 8),
                        _ChannelBadge(
                            icon: '💬',
                            label: 'WhatsApp',
                            color: Color(0xFF22C795)),
                        SizedBox(width: 8),
                        _ChannelBadge(
                            icon: '✈️',
                            label: 'Telegram',
                            color: Color(0xFF27A7E5)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('RECENT ALERTS',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: GXColors.textSoft,
                            letterSpacing: 0.14)),
                    const SizedBox(height: 8),
                    ..._notifications.map((n) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _NotifCard(notif: n),
                        )),
                  ]),
                ),
              ),
            ],
          ),
        ),
      );
}

class _NotifItem {
  const _NotifItem(this.icon, this.title, this.body, this.type, this.time);
  final String icon;
  final String title;
  final String body;
  final String type;
  final String time;
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.notif});
  final _NotifItem notif;

  Color get _accent => switch (notif.type) {
        'warning' => GXColors.warning,
        'success' => GXColors.success,
        'shield' => GXColors.violet,
        _ => GXColors.blue,
      };

  @override
  Widget build(BuildContext context) => GXCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _accent.withValues(alpha: 0.27)),
              ),
              child: Center(
                  child:
                      Text(notif.icon, style: const TextStyle(fontSize: 17))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notif.title,
                            style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: GXColors.textWhite)),
                      ),
                      Text(notif.time,
                          style: const TextStyle(
                              fontSize: 11, color: GXColors.textMute)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(notif.body,
                      style: const TextStyle(
                          fontSize: 13, color: GXColors.textSoft, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ChannelBadge extends StatelessWidget {
  const _ChannelBadge(
      {required this.icon, required this.label, required this.color});
  final String icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.27)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      );
}

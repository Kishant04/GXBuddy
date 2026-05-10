import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/gx_colors.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/gx_card.dart';
import '../dev/dev_settings_screen.dart';
import '../notifications/notification_preview_screen.dart';
import 'profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 60, 18, 130),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Profile card
              GXCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                            colors: [GXColors.violetLight, GXColors.pink]),
                        boxShadow: [
                          BoxShadow(
                              color: GXColors.violet.withValues(alpha: 0.33),
                              blurRadius: 30)
                        ],
                      ),
                      child: Center(
                        child: user.name.isEmpty
                            ? const SizedBox(
                                width: 28, height: 28,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: GXColors.textWhite),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                        user.name.isEmpty ? 'Loading...' : user.name,
                        style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: GXColors.textWhite,
                            letterSpacing: -0.02)),
                    const SizedBox(height: 2),
                    Text(
                      'Level ${user.level} saver · ${user.streakDays} day streak 🔥',
                      style: const TextStyle(
                          fontSize: 12.5, color: GXColors.textSoft),
                    ),
                    const SizedBox(height: 16),
                    _StatsRow(
                        monthlyIncome: user.monthlyIncome,
                        streakDays: user.streakDays),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notifications
              _Section(
                title: 'Notifications',
                children: [
                  _SettingRow(
                    icon: '📲',
                    label: 'Push notifications',
                    value: user.pushEnabled,
                    onToggle: notifier.togglePush,
                  ),
                  _SettingRow(
                    icon: '💬',
                    label: 'WhatsApp alerts',
                    value: user.whatsappEnabled,
                    onToggle: notifier.toggleWhatsapp,
                  ),
                  _SettingRow(
                    icon: '✈️',
                    label: 'Telegram alerts',
                    value: user.telegramEnabled,
                    onToggle: notifier.toggleTelegram,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Privacy
              _Section(
                title: 'Privacy',
                children: [
                  _SettingRow(
                    icon: '🕶️',
                    label: 'Anonymous squad progress',
                    subtitle: 'Hide your name in shared goals',
                    value: user.anonymousSquad,
                    onToggle: notifier.toggleAnonymousSquad,
                  ),
                  _SettingRow(
                    icon: '👁️',
                    label: 'Hide exact balances',
                    subtitle: 'Show % only on social cards',
                    value: user.hideBalances,
                    onToggle: notifier.toggleHideBalances,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Security
              _Section(
                title: 'Security',
                children: [
                  _SettingRow(
                      icon: '🧊',
                      label: 'Freeze card',
                      danger: true,
                      chevron: true),
                  _SettingRow(
                      icon: '📉',
                      label: 'Spending limit',
                      chevron: true,
                      right: 'RM400/wk'),
                  _SettingRow(
                      icon: '🚨', label: 'Scam alert support', chevron: true),
                ],
              ),
              const SizedBox(height: 14),

              // Notification preview shortcut
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const NotificationPreviewScreen())),
                child: GXCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: GXColors.violet.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: GXColors.violetLight, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notification Preview',
                                style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: GXColors.textWhite)),
                            Text('See how GXBuddy notifies you',
                                style: TextStyle(
                                    fontSize: 11, color: GXColors.textSoft)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: GXColors.textMute, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Sign out
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () async {
                  final store = ref.read(authTokenStoreProvider);
                  await store.clearSession();
                  if (context.mounted) context.go('/login');
                },
                child: GXCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: GXColors.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.logout_rounded,
                            color: GXColors.danger, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Text('Sign out',
                          style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: GXColors.danger)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Developer Settings
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const DevSettingsScreen())),
                child: GXCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0x15FFFFFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.developer_mode_rounded,
                            color: GXColors.textSoft, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Developer Settings',
                                style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: GXColors.textWhite)),
                            Text('API URL · User ID · Token · Mock mode',
                                style: TextStyle(
                                    fontSize: 11, color: GXColors.textSoft)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: GXColors.textMute, size: 20),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.monthlyIncome, required this.streakDays});
  final double monthlyIncome;
  final int streakDays;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            _Stat(
                value: 'RM${monthlyIncome.toStringAsFixed(0)}',
                label: 'Income/mo'),
            Container(width: 1, height: 60, color: GXColors.border),
            const _Stat(value: 'RM800', label: 'Threshold'),
            Container(width: 1, height: 60, color: GXColors.border),
            _Stat(value: '$streakDays', label: 'Streak'),
          ],
        ),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: const Color(0x0C150535),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: GXColors.textWhite)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      fontSize: 10.5, color: GXColors.textMute)),
            ],
          ),
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: GXColors.textSoft,
                  letterSpacing: 0.12),
            ),
          ),
          GXCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: children),
          ),
        ],
      );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.value,
    this.onToggle,
    this.chevron = false,
    this.right,
    this.danger = false,
  });

  final String icon;
  final String label;
  final String? subtitle;
  final bool? value;
  final VoidCallback? onToggle;
  final bool chevron;
  final String? right;
  final bool danger;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: GXColors.border)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0x0FFFFFFF),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 15))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: danger
                            ? const Color(0xFFFF8A8A)
                            : GXColors.textWhite,
                      ),
                    ),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: const TextStyle(
                              fontSize: 11, color: GXColors.textMute)),
                  ],
                ),
              ),
              if (right != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(right!,
                      style: const TextStyle(
                          fontSize: 12, color: GXColors.textSoft)),
                ),
              if (value != null)
                _GXToggle(value: value!, onChanged: (_) => onToggle?.call()),
              if (chevron)
                const Icon(Icons.chevron_right,
                    color: GXColors.textMute, size: 20),
            ],
          ),
        ),
      );
}

class _GXToggle extends StatelessWidget {
  const _GXToggle({required this.value, required this.onChanged});
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

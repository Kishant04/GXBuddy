import 'package:flutter/material.dart';
import '../../core/theme/gx_colors.dart';
import '../../models/mascot.dart';
import '../../shared/widgets/animated_mascot.dart';
import '../../core/router/app_router.dart';

class GXBankEntryScreen extends StatefulWidget {
  const GXBankEntryScreen({super.key});

  @override
  State<GXBankEntryScreen> createState() => _GXBankEntryScreenState();
}

class _GXBankEntryScreenState extends State<GXBankEntryScreen> {
  bool _balanceHidden = false;

  void _openGXBuddy() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const _GXBuddyHost(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08001A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.7),
            radius: 1.6,
            colors: [Color(0xFF5B1A9E), Color(0xFF2A0A5C), Color(0xFF0E0228), Color(0xFF08001A)],
            stops: [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _AppBar(balanceHidden: _balanceHidden, onToggle: () => setState(() => _balanceHidden = !_balanceHidden)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Balance
                      _BalanceSection(hidden: _balanceHidden),
                      const SizedBox(height: 20),
                      // Action buttons
                      _ActionRow(),
                      const SizedBox(height: 22),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Your everyday account',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: GXColors.textWhite)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 3-card row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(child: _AccountCard(label: 'Main account', amount: 'RM3,900.00', body: _ViewTransactions())),
                            const SizedBox(width: 10),
                            Expanded(child: _AccountCard(label: 'Saving Pockets', amount: 'RM1,507.38', body: _PocketAvatars())),
                            const SizedBox(width: 10),
                            Expanded(child: _BuddyCard(onTap: _openGXBuddy)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text('For you today',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: GXColors.textWhite)),
                      ),
                      const SizedBox(height: 12),
                      // GXBuddy promo card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _BuddyPromoCard(onTap: _openGXBuddy),
                      ),
                      const SizedBox(height: 22),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Text('Your insights',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: GXColors.textWhite)),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: const [
                            Expanded(child: _InsightChip(color: Color(0xFFFFB347), label: 'Spending up 18%')),
                            SizedBox(width: 10),
                            Expanded(child: _InsightChip(color: Color(0xFF60A5FA), label: '2 bills coming')),
                          ],
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
}

// ── GXBuddy host — wraps the go_router app so the bank screen can push to it ──
class _GXBuddyHost extends StatelessWidget {
  const _GXBuddyHost();

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true, brightness: Brightness.dark,
          scaffoldBackgroundColor: GXColors.bgPrimary,
          colorScheme: const ColorScheme.dark(primary: GXColors.violet, surface: GXColors.bgCard),
        ),
        routerConfig: appRouter,
      );
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  const _AppBar({required this.balanceHidden, required this.onToggle});
  final bool balanceHidden;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text('Total balance',
                          style: TextStyle(fontSize: 13, color: Color(0xBFFFFFFF))),
                      SizedBox(width: 6),
                      Icon(Icons.shield, color: GXColors.success, size: 14),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.help_outline_rounded, color: GXColors.textSoft, size: 20),
              onPressed: () {},
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: GXColors.textWhite, size: 20),
                  onPressed: () {},
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: GXColors.pink, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: GXColors.pink, blurRadius: 8)],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

class _BalanceSection extends StatelessWidget {
  const _BalanceSection({required this.hidden});
  final bool hidden;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  hidden ? '••••••••' : 'RM3,900.00',
                  style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: GXColors.textWhite, letterSpacing: -0.03),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.visibility_outlined, color: Color(0xBFFFFFFF), size: 18),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Text('Balance info', style: TextStyle(fontSize: 12, color: Color(0x99FFFFFF))),
                SizedBox(width: 2),
                Icon(Icons.chevron_right, color: Color(0x99FFFFFF), size: 14),
              ],
            ),
          ],
        ),
      );
}

class _ActionRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0x12FFFFFF), Color(0x05FFFFFF)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x14FFFFFF)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ActionItem(icon: Icons.add, label: 'Add Money'),
              _ActionItem(icon: Icons.qr_code_scanner, label: 'Scan QR'),
              _ActionItem(icon: Icons.send_rounded, label: 'Send Money'),
            ],
          ),
        ),
      );
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0xFFA45EFF), GXColors.violet, GXColors.violetDeep],
              ),
              boxShadow: [BoxShadow(color: GXColors.violet.withValues(alpha: 0.50), blurRadius: 18)],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GXColors.textWhite)),
        ],
      );
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.label, required this.amount, required this.body});
  final String label;
  final String amount;
  final Widget body;

  @override
  Widget build(BuildContext context) => Container(
        height: 124,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0x0DFFFFFF), Color(0x05FFFFFF)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x14FFFFFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0x8CFFFFFF))),
            Text(amount, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: GXColors.textWhite, letterSpacing: -0.02)),
            body,
          ],
        ),
      );
}

class _ViewTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Text(
        'View transactions ›',
        style: TextStyle(fontSize: 10.5, color: Color(0x99FFFFFF)),
      );
}

class _PocketAvatars extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const colors = [Color(0xFFA855F7), Color(0xFF22C796), Color(0xFF60A5FA), Color(0xFFF8326D)];
    return Row(
      children: [
        ...colors.asMap().entries.map((e) => Transform.translate(
              offset: Offset(e.key * -8.0, 0),
              child: Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: e.value,
                  border: Border.all(color: const Color(0xFF15052D), width: 2),
                ),
              ),
            )),
        const SizedBox(width: 4),
        const Text('+4', style: TextStyle(fontSize: 10.5, color: Color(0x99FFFFFF), fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _BuddyCard extends StatelessWidget {
  const _BuddyCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 124,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x47771FFF), Color(0x2EF8326D)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x8CD8B4FE), width: 1.5),
            boxShadow: [BoxShadow(color: GXColors.violet.withValues(alpha: 0.28), blurRadius: 28)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 40, height: 40,
                    child: AnimatedMascot(state: MascotState.calm, size: 40),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: GXColors.success.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: GXColors.success.withValues(alpha: 0.50)),
                    ),
                    child: const Text('NEW', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFF5DE3B6), letterSpacing: 0.06)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('GXBuddy', style: TextStyle(fontSize: 10.5, color: Color(0xA6FFFFFF))),
                  Text('Smart save\nbuddy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GXColors.textWhite, height: 1.2)),
                  SizedBox(height: 4),
                  Text('🔥 8d · Tap →', style: TextStyle(fontSize: 10.5, color: GXColors.gold, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      );
}

class _BuddyPromoCard extends StatelessWidget {
  const _BuddyPromoCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0x1E1FB287), Color(0x0AFFFFFF)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x4D22C796)),
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [GXColors.success, GXColors.successDark]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: GXColors.success.withValues(alpha: 0.40), blurRadius: 16)],
              ),
              child: const Icon(Icons.savings_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GXBuddy spotted RM2 to save',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GXColors.textWhite)),
                  const SizedBox(height: 2),
                  const Text('3 food deliveries this week. Round up?',
                      style: TextStyle(fontSize: 11.5, color: Color(0xA6FFFFFF))),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0x4DFFFFFF)),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text('Open GXBuddy ›',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: GXColors.textWhite)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.12), const Color(0x05FFFFFF)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.27)),
        ),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 8)])),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GXColors.textWhite))),
          ],
        ),
      );
}

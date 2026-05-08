import 'package:flutter/material.dart';
import '../../../core/theme/gx_colors.dart';

class SalarySplitAnimation extends StatefulWidget {
  const SalarySplitAnimation({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<SalarySplitAnimation> createState() => _SalarySplitAnimationState();
}

class _SalarySplitAnimationState extends State<SalarySplitAnimation>
    with TickerProviderStateMixin {
  late AnimationController _main;
  int _stage = 0; // 0=detect 1=reveal 2=splitting 3=done

  static const _pockets = [
    _PocketSlot('Emergency', 240, '🛟', Color(0xFF22C796), 20),
    _PocketSlot('PTPTN', 120, '📚', Color(0xFF60A5FA), 10),
    _PocketSlot('Travel', 60, '✈️', GXColors.pink, 5),
  ];

  @override
  void initState() {
    super.initState();
    _main = AnimationController(vsync: this, duration: const Duration(seconds: 5));

    Future.delayed(const Duration(milliseconds: 60), () => setState(() => _stage = 0));
    Future.delayed(const Duration(milliseconds: 700), () { if (mounted) setState(() => _stage = 1); });
    Future.delayed(const Duration(milliseconds: 1700), () { if (mounted) setState(() => _stage = 2); });
    Future.delayed(const Duration(milliseconds: 4200), () { if (mounted) setState(() => _stage = 3); });
    Future.delayed(const Duration(milliseconds: 5200), () {
      if (mounted) widget.onComplete();
    });

    _main.forward();
  }

  @override
  void dispose() { _main.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: const Color(0xEB02000A),
        child: Stack(
          children: [
            // Radial bloom
            Center(
              child: Container(
                width: 480, height: 480,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x8C771FFF), Color(0x38F8326D), Colors.transparent],
                    stops: [0.0, 0.35, 0.70],
                  ),
                ),
              ),
            ),

            // Stage label
            Positioned(
              top: MediaQuery.of(context).size.height * 0.14,
              left: 0, right: 0,
              child: Text(
                _stageLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800,
                  color: Color(0xFFD6BFFF), letterSpacing: 0.22,
                ),
              ),
            ),

            // SMS ping (stage 0)
            if (_stage == 0)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.24,
                left: 40, right: 40,
                child: _SmsPing(),
              ),

            // Big amount
            if (_stage >= 1)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeInOutCubic,
                top: _stage == 1
                    ? MediaQuery.of(context).size.height * 0.28
                    : MediaQuery.of(context).size.height * 0.24,
                left: 0, right: 0,
                child: _AmountReveal(stage: _stage),
              ),

            // Coin particles
            if (_stage >= 2)
              ..._buildCoins(context),

            // Pocket targets
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.22,
              left: 16, right: 16,
              child: Row(
                children: _pockets.map((p) => Expanded(
                  child: _PocketTarget(pocket: p, active: _stage >= 2, settled: _stage >= 3),
                )).toList(),
              ),
            ),

            // Status bar
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.14,
              left: 0, right: 0,
              child: _StatusBar(stage: _stage),
            ),
          ],
        ),
      ),
    );
  }

  String get _stageLabel => switch (_stage) {
        0 || 1 => '· DETECTING SALARY ·',
        2 => '· AUTOPILOT ENGAGED ·',
        _ => '· DONE ·',
      };

  List<Widget> _buildCoins(BuildContext context) {
    return List.generate(18, (i) {
      final delay = Duration(milliseconds: i * 50);
      final targetIdx = i % 3;
      return _Coin(delay: delay, targetIndex: targetIdx);
    });
  }
}

class _SmsPing extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x12FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x1AFFFFFF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: GXColors.success, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: GXColors.success, blurRadius: 12)],
              ),
            ),
            const SizedBox(width: 10),
            const Text('Maybank · Credit Alert  ', style: TextStyle(fontSize: 12.5, color: GXColors.textSoft)),
            const Text('RM1,200.00', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: GXColors.textWhite)),
          ],
        ),
      );
}

class _AmountReveal extends StatelessWidget {
  const _AmountReveal({required this.stage});
  final int stage;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.white, GXColors.gold],
            ).createShader(bounds),
            child: Text(
              '+RM1,200.00',
              style: TextStyle(
                fontSize: stage == 1 ? 52 : 38,
                fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: -0.04, height: 1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            stage == 1 ? 'Salary received from Maybank' : 'Salary · 8 May 2026',
            style: const TextStyle(fontSize: 12, color: GXColors.textSoft, letterSpacing: 0.08),
          ),
        ],
      );
}

class _PocketTarget extends StatelessWidget {
  const _PocketTarget({required this.pocket, required this.active, required this.settled});
  final _PocketSlot pocket;
  final bool active;
  final bool settled;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [pocket.color.withValues(alpha: 0.12), pocket.color.withValues(alpha: 0.05)],
                )
              : null,
          color: active ? null : const Color(0x08FFFFFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: active ? pocket.color.withValues(alpha: 0.33) : const Color(0x14FFFFFF)),
          boxShadow: settled
              ? [BoxShadow(color: pocket.color.withValues(alpha: 0.33), blurRadius: 24)]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [pocket.color, pocket.color.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [BoxShadow(color: pocket.color.withValues(alpha: 0.40), blurRadius: 16)],
              ),
              child: Center(child: Text(pocket.icon, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(height: 6),
            Text(pocket.name, style: const TextStyle(fontSize: 10.5, color: GXColors.textSoft, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(
              '+RM${pocket.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GXColors.textWhite, letterSpacing: -0.02),
            ),
            Text(
              '${pocket.percent}%',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: pocket.color),
            ),
          ],
        ),
      );
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.stage});
  final int stage;

  @override
  Widget build(BuildContext context) {
    final done = stage >= 3;
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: done ? const Color(0x1F22C796) : const Color(0x0FFFFFFF),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: done ? const Color(0x8C22C796) : const Color(0x1AFFFFFF)),
        ),
        child: Text(
          done
              ? '✓  RM420 saved before you could spend it'
              : stage >= 2
                  ? '· Splitting into 3 pockets…'
                  : '· GXBuddy is on it ·',
          style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700,
            color: done ? const Color(0xFF5DE3B6) : GXColors.textWhite,
          ),
        ),
      ),
    );
  }
}

class _Coin extends StatefulWidget {
  const _Coin({required this.delay, required this.targetIndex});
  final Duration delay;
  final int targetIndex;

  @override
  State<_Coin> createState() => _CoinState();
}

class _CoinState extends State<_Coin> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInCubic);
    Future.delayed(widget.delay, () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const targetOffsets = [-88.0, 0.0, 88.0];
    final tx = targetOffsets[widget.targetIndex];

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        if (_anim.value == 0) return const SizedBox.shrink();
        return Positioned(
          top: size.height * 0.32 + _anim.value * 230,
          left: size.width / 2 + tx - 11,
          child: Opacity(
            opacity: (1 - _anim.value).clamp(0.0, 1.0),
            child: Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.3, -0.3),
                  colors: [Color(0xFFFFE89A), GXColors.gold, Color(0xFFC9952A)],
                  stops: [0.0, 0.6, 1.0],
                ),
                border: Border.all(color: const Color(0xFFFFE89A), width: 1.5),
                boxShadow: [BoxShadow(color: GXColors.gold.withValues(alpha: 0.55), blurRadius: 14)],
              ),
              child: const Center(
                child: Text('\$', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF7A4A00))),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PocketSlot {
  const _PocketSlot(this.name, this.amount, this.icon, this.color, this.percent);
  final String name;
  final double amount;
  final String icon;
  final Color color;
  final int percent;
}

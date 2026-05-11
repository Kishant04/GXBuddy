import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/gx_colors.dart';
import '../../shared/widgets/gx_button.dart';

class HighRiskModal extends StatefulWidget {
  const HighRiskModal({
    super.key,
    required this.onClose,
    required this.onCancel,
    required this.onContinue,
    required this.onRoundUp,
  });

  final VoidCallback onClose;
  final VoidCallback onCancel;
  final VoidCallback onContinue;
  final VoidCallback onRoundUp;

  @override
  State<HighRiskModal> createState() => _HighRiskModalState();
}

class _HighRiskModalState extends State<HighRiskModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  int _secsLeft = 10;
  double _riskFill = 0;
  int _riskScore = 0;
  Timer? _countdownTimer;
  Timer? _scoreTimer;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _slideAnim = Tween(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _slideCtrl, curve: const Cubic(0.16, 0.84, 0.32, 1)),
    );
    _slideCtrl.forward();

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _riskFill = 0.82);
    });

    int score = 0;
    _scoreTimer = Timer.periodic(const Duration(milliseconds: 22), (t) {
      score += 4;
      if (score >= 82) {
        score = 82;
        t.cancel();
      }
      if (mounted) setState(() => _riskScore = score);
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secsLeft > 0) _secsLeft--;
      });
    });
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _countdownTimer?.cancel();
    _scoreTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urgent = _secsLeft <= 3;
    final ringColor = urgent ? GXColors.danger : GXColors.pink;
    final ringPct = _secsLeft / 10.0;

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withValues(alpha: 0.60),
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnim,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1F0A4D),
                      Color(0xFF0E0228),
                      Color(0xFF08001A)
                    ],
                    stops: [0.0, 0.75, 1.0],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border(
                    top: BorderSide(color: Color(0x73F8326D)),
                    left: BorderSide(color: Color(0x73F8326D)),
                    right: BorderSide(color: Color(0x73F8326D)),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xB3000000),
                        blurRadius: 80,
                        offset: Offset(0, -30))
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0x30FFFFFF),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Countdown ring
                      _CountdownRing(
                          secsLeft: _secsLeft,
                          ringPct: ringPct,
                          ringColor: ringColor),
                      const SizedBox(height: 8),
                      const Text(
                        '· Pause Before You Spend ·',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF7DA1),
                            letterSpacing: 0.2),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(children: [
                          TextSpan(
                              text: 'RM',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: GXColors.textSoft)),
                          TextSpan(
                              text: '100.00',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: GXColors.textWhite,
                                  letterSpacing: -0.035)),
                          TextSpan(
                              text: ' · Shopee',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: GXColors.textSoft)),
                        ]),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'This will push you past your weekly limit. Take a beat — there\'s a smarter move below.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13,
                              color: GXColors.textSoft,
                              height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Risk meter
                      _RiskMeter(riskFill: _riskFill, riskScore: _riskScore),
                      const SizedBox(height: 14),
                      // Actions
                      GXButton(
                        label: '💎  Round Up RM2 to Emergency Instead',
                        onPressed: widget.onRoundUp,
                        variant: GXButtonVariant.success,
                        size: GXButtonSize.lg,
                        expand: true,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GXButton(
                              label: 'Continue Anyway',
                              onPressed: widget.onContinue,
                              variant: GXButtonVariant.ghost,
                              size: GXButtonSize.md,
                              expand: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GXButton(
                              label: 'Cancel — Smart move',
                              onPressed: widget.onCancel,
                              variant: GXButtonVariant.pink,
                              size: GXButtonSize.md,
                              expand: true,
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
      ),
    );
  }
}

class _CountdownRing extends StatelessWidget {
  const _CountdownRing(
      {required this.secsLeft, required this.ringPct, required this.ringColor});
  final int secsLeft;
  final double ringPct;
  final Color ringColor;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 108,
        height: 108,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ringColor.withValues(alpha: 0.20),
                    Colors.transparent
                  ],
                ),
              ),
            ),
            // Ring
            CustomPaint(
              size: const Size(108, 108),
              painter: _RingPainter(progress: ringPct, color: ringColor),
            ),
            // Text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$secsLeft',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: GXColors.textWhite,
                    letterSpacing: -0.04,
                    height: 1,
                  ),
                ),
                const Text(
                  'BREATHE',
                  style: TextStyle(
                      fontSize: 9,
                      color: GXColors.textMute,
                      letterSpacing: 0.16,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      );
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.40;

    final trackPaint = Paint()
      ..color = const Color(0x0FFFFFFF)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final sweepAngle = 2 * pi * progress;
      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: -pi / 2 + sweepAngle,
          colors: [const Color(0xFFFBB347), GXColors.pink, GXColors.danger],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _RiskMeter extends StatelessWidget {
  const _RiskMeter({required this.riskFill, required this.riskScore});
  final double riskFill;
  final int riskScore;

  static const _tags = [
    _RiskTag('🌙 Late-night purchase', GXColors.warning),
    _RiskTag('📈 178% above weekly avg', GXColors.pink),
    _RiskTag('📱 Phone bill due in 2d', Color(0xFF60A5FA)),
  ];

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x1FF8326D), Color(0x0AF8326D)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x47F8326D)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0x38F8326D),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: const Color(0x66F8326D)),
                  ),
                  child: const Center(
                      child: Text('⚠', style: TextStyle(fontSize: 11))),
                ),
                const SizedBox(width: 7),
                const Expanded(
                    child: Text('Risk score',
                        style: TextStyle(
                            fontSize: 12,
                            color: GXColors.textSoft,
                            fontWeight: FontWeight.w600))),
                Text(
                  '$riskScore',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF7DA1),
                      letterSpacing: -0.025),
                ),
                const Text(' / 100',
                    style: TextStyle(fontSize: 13, color: GXColors.textMute)),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (_, c) => Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0x0FFFFFFF),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: riskFill,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFBB347),
                          GXColors.pink,
                          GXColors.danger
                        ],
                      ),
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [
                        BoxShadow(
                            color: GXColors.danger.withValues(alpha: 0.40),
                            blurRadius: 14)
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SAFE',
                    style: TextStyle(
                        fontSize: 9.5,
                        color: GXColors.textMute,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.06)),
                Text('WATCH',
                    style: TextStyle(
                        fontSize: 9.5,
                        color: GXColors.textMute,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.06)),
                Text('HIGH RISK',
                    style: TextStyle(
                        fontSize: 9.5,
                        color: GXColors.textMute,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.06)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _tags
                  .map((t) => _TagChip(label: t.label, color: t.color))
                  .toList(),
            ),
          ],
        ),
      );
}

class _RiskTag {
  const _RiskTag(this.label, this.color);
  final String label;
  final Color color;
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: 0.33)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: GXColors.textWhite)),
      );
}

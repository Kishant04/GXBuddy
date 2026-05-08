import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/mascot.dart';
import '../../core/theme/gx_colors.dart';

class AnimatedMascot extends StatefulWidget {
  const AnimatedMascot({super.key, required this.state, this.size = 120});

  final MascotState state;
  final double size;

  @override
  State<AnimatedMascot> createState() => _AnimatedMascotState();
}

class _AnimatedMascotState extends State<AnimatedMascot>
    with TickerProviderStateMixin {
  late AnimationController _bodyCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _sparkleCtrl;

  late Animation<double> _bodyAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _bodyCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _sparkleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

    _bodyAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bodyCtrl, curve: Curves.easeInOut),
    );
    _glowAnim = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _glowCtrl.repeat(reverse: true);
    _sparkleCtrl.repeat();
    switch (widget.state) {
      case MascotState.calm:
        _bodyCtrl
          ..duration = const Duration(milliseconds: 3200)
          ..repeat(reverse: true);
      case MascotState.alert:
        _bodyCtrl
          ..duration = const Duration(milliseconds: 1600)
          ..repeat(reverse: true);
      case MascotState.panicked:
        _bodyCtrl
          ..duration = const Duration(milliseconds: 400)
          ..repeat(reverse: true);
      case MascotState.celebrating:
        _bodyCtrl
          ..duration = const Duration(milliseconds: 1100)
          ..repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedMascot old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state) {
      _bodyCtrl.reset();
      _startAnimations();
    }
  }

  @override
  void dispose() {
    _bodyCtrl.dispose();
    _glowCtrl.dispose();
    _sparkleCtrl.dispose();
    super.dispose();
  }

  Color get _glowColor => switch (widget.state) {
        MascotState.calm => GXColors.success,
        MascotState.alert => GXColors.warning,
        MascotState.panicked => GXColors.danger,
        MascotState.celebrating => GXColors.celebrationLight,
      };

  Color get _screenColor => switch (widget.state) {
        MascotState.calm => const Color(0xFF5BFF8C),
        MascotState.alert => const Color(0xFFFFB347),
        MascotState.panicked => const Color(0xFFFF6B6B),
        MascotState.celebrating => const Color(0xFF5BFF8C),
      };

  Offset _bodyOffset(double t) => switch (widget.state) {
        MascotState.calm => Offset(0, -6 * sin(t * pi)),
        MascotState.alert => Offset(0, -3 * sin(t * pi)),
        MascotState.panicked => Offset(4 * sin(t * 2 * pi), 2 * cos(t * 2 * pi)),
        MascotState.celebrating => Offset(0, -8 * sin(t * pi)),
      };

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return AnimatedBuilder(
      animation: Listenable.merge([_bodyCtrl, _glowCtrl, _sparkleCtrl]),
      builder: (context, _) {
        final offset = _bodyOffset(_bodyAnim.value);
        final glowOpacity = _glowAnim.value;

        return SizedBox(
          width: s,
          height: s,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Ambient glow
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _glowColor.withValues(alpha: 0.35 * glowOpacity),
                        Colors.transparent,
                      ],
                      radius: 0.9,
                    ),
                  ),
                ),
              ),
              // Body
              Transform.translate(
                offset: offset,
                child: CustomPaint(
                  size: Size(s, s),
                  painter: _MascotPainter(
                    state: widget.state,
                    screenColor: _screenColor,
                    animValue: _bodyAnim.value,
                  ),
                ),
              ),
              // Celebrating sparkles
              if (widget.state == MascotState.celebrating)
                ..._buildSparkles(s),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSparkles(double s) {
    const positions = [
      Offset(-0.45, -0.42),
      Offset(0.47, -0.35),
      Offset(-0.50, 0.15),
      Offset(0.50, 0.20),
      Offset(0.0, -0.55),
    ];
    return positions.asMap().entries.map((entry) {
      final i = entry.key;
      final p = entry.value;
      final delay = i * 0.2;
      final t = (_sparkleCtrl.value + delay) % 1.0;
      final opacity = (sin(t * pi)).clamp(0.0, 1.0);
      return Positioned(
        left: s / 2 + p.dx * s * 0.5,
        top: s / 2 + p.dy * s * 0.5,
        child: Opacity(
          opacity: opacity,
          child: const _Sparkle(size: 12),
        ),
      );
    }).toList();
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size, size),
        painter: _SparklePainter(),
      );
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFD66B);
    final c = size.width / 2;
    final path = Path()
      ..moveTo(c, 0)
      ..lineTo(c + 1.5, c - 1.5)
      ..lineTo(size.width, c)
      ..lineTo(c + 1.5, c + 1.5)
      ..lineTo(c, size.height)
      ..lineTo(c - 1.5, c + 1.5)
      ..lineTo(0, c)
      ..lineTo(c - 1.5, c - 1.5)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _MascotPainter extends CustomPainter {
  const _MascotPainter({
    required this.state,
    required this.screenColor,
    required this.animValue,
  });

  final MascotState state;
  final Color screenColor;
  final double animValue;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // scale everything to the canvas
    canvas.scale(w / 220, h / 220);

    _drawBody(canvas);
    _drawScreen(canvas);
    _drawFace(canvas);
    _drawControls(canvas);
    _drawAntenna(canvas);
  }

  void _drawBody(Canvas canvas) {
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(const Rect.fromLTWH(58, 200, 104, 12), shadowPaint);

    // Legs
    final limbPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF7E8B95), Color(0xFF3F4750)],
      ).createShader(const Rect.fromLTWH(0, 0, 220, 220));
    final legRadius = const Radius.circular(4);
    canvas.drawRRect(RRect.fromLTRBR(72, 178, 86, 200, legRadius), limbPaint);
    canvas.drawRRect(RRect.fromLTRBR(134, 178, 148, 200, legRadius), limbPaint);

    // Feet
    final footPaint = Paint()..color = const Color(0xFF2A2F36);
    canvas.drawOval(const Rect.fromLTWH(65, 196, 28, 10), footPaint);
    canvas.drawOval(const Rect.fromLTWH(127, 196, 28, 10), footPaint);

    // Side bevel
    final sidePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft, end: Alignment.centerRight,
        colors: [Color(0xFF3B156A), Color(0xFF1A063C)],
      ).createShader(const Rect.fromLTWH(170, 50, 20, 140));
    final sidePath = Path()
      ..moveTo(170, 50)
      ..lineTo(186, 64)
      ..lineTo(186, 174)
      ..lineTo(170, 188)
      ..close();
    canvas.drawPath(sidePath, sidePaint);

    // Main body
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [Color(0xFF5C2A8E), Color(0xFF3B156A), Color(0xFF1F0844)],
        stops: [0.0, 0.55, 1.0],
      ).createShader(const Rect.fromLTWH(50, 38, 122, 154));
    final bodyPath = Path()
      ..moveTo(50, 50)
      ..cubicTo(50, 38, 50, 38, 62, 38)
      ..lineTo(160, 38)
      ..cubicTo(172, 38, 172, 38, 172, 50)
      ..lineTo(172, 178)
      ..cubicTo(172, 192, 172, 192, 158, 192)
      ..lineTo(64, 192)
      ..cubicTo(50, 192, 50, 192, 50, 178)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Top highlight
    final highlightPaint = Paint()
      ..color = const Color(0x30FFFFFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(58, 44), const Offset(162, 44), highlightPaint);

    // Arms
    _drawArm(canvas, isRight: false);
    _drawArm(canvas, isRight: true);
  }

  void _drawArm(Canvas canvas, {required bool isRight}) {
    final paint = Paint()
      ..color = const Color(0xFF7E8B95)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final startX = isRight ? 178.0 : 42.0;
    final endX = isRight ? 200.0 : 22.0;
    final endY = (state == MascotState.celebrating && isRight) ? 70.0 : 138.0;

    canvas.drawLine(Offset(startX, 120), Offset(endX, endY), paint);

    // Joint dot
    final jointPaint = Paint()..color = const Color(0xFF5BFF8C);
    final borderPaint = Paint()
      ..color = const Color(0xFF0F6E56)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(startX, 120), 6, jointPaint);
    canvas.drawCircle(Offset(startX, 120), 6, borderPaint);

    // Hand
    final handPaint = Paint()..color = const Color(0xFF3A4048);
    canvas.drawCircle(Offset(endX, endY), 8, handPaint);
    final handBorder = Paint()
      ..color = const Color(0xFF1C1F24)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(endX, endY), 8, handBorder);
  }

  void _drawScreen(Canvas canvas) {
    // Screen bezel
    final bezelPaint = Paint()..color = const Color(0xFF0A0A14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(64, 52, 94, 74), const Radius.circular(10)),
      bezelPaint,
    );
    final bezelBorder = Paint()
      ..color = const Color(0xFFF8326D)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(64, 52, 94, 74), const Radius.circular(10)),
      bezelBorder,
    );

    // Screen fill
    final screenPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.5),
        radius: 1.0,
        colors: [
          const Color(0xD9E0FFE8),
          screenColor,
          Color.lerp(screenColor, Colors.black, 0.3)!,
        ],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(const Rect.fromLTWH(68, 56, 86, 66));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(68, 56, 86, 66), const Radius.circular(7)),
      screenPaint,
    );

    // CRT shine
    final shinePaint = Paint()..color = const Color(0x59FFFFFF);
    canvas.drawOval(const Rect.fromLTWH(68, 62, 28, 12), shinePaint);

    // Scanlines
    final scanPaint = Paint()..color = const Color(0x12000000);
    for (var i = 0; i < 6; i++) {
      canvas.drawRect(Rect.fromLTWH(68, 56 + i * 11.0, 86, 1), scanPaint);
    }
  }

  void _drawFace(Canvas canvas) {
    final facePaint = Paint()..color = const Color(0xFF0A2818);

    switch (state) {
      case MascotState.calm:
        _drawHappyFace(canvas, facePaint);
      case MascotState.alert:
        _drawWorriedFace(canvas, facePaint);
      case MascotState.panicked:
        _drawShockedFace(canvas, facePaint);
      case MascotState.celebrating:
        _drawStarFace(canvas, facePaint);
    }
  }

  void _drawHappyFace(Canvas canvas, Paint p) {
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(84, 78, 10, 14), const Radius.circular(2)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(128, 78, 10, 14), const Radius.circular(2)), p);
    // Pupils
    canvas.drawCircle(const Offset(89, 83), 2.4, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(133, 83), 2.4, Paint()..color = Colors.white);
    // Smile
    final smile = Paint()
      ..color = const Color(0xFF0A2818)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final smilePath = Path()
      ..moveTo(94, 102)
      ..quadraticBezierTo(111, 116, 128, 102);
    canvas.drawPath(smilePath, smile);
  }

  void _drawWorriedFace(Canvas canvas, Paint p) {
    // Brows
    final browPaint = Paint()..color = const Color(0xFF0A2818);
    canvas.save();
    canvas.translate(87, 75.5);
    canvas.rotate(-12 * pi / 180);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-7, -1.5, 14, 3), const Radius.circular(1.5)), browPaint);
    canvas.restore();
    canvas.save();
    canvas.translate(135, 75.5);
    canvas.rotate(12 * pi / 180);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-7, -1.5, 14, 3), const Radius.circular(1.5)), browPaint);
    canvas.restore();
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(84, 80, 10, 14), const Radius.circular(2)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(128, 80, 10, 14), const Radius.circular(2)), p);
    // Flat concerned mouth
    final mouth = Paint()
      ..color = const Color(0xFF0A2818)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final mouthPath = Path()..moveTo(95, 108)..quadraticBezierTo(111, 102, 127, 108);
    canvas.drawPath(mouthPath, mouth);
    // Sweat drop
    final sweat = Paint()..color = const Color(0xFF7DD3FC);
    final dropPath = Path()
      ..moveTo(150, 78)
      ..quadraticBezierTo(147, 84, 150, 89)
      ..quadraticBezierTo(153, 84, 150, 78)
      ..close();
    canvas.drawPath(dropPath, sweat);
  }

  void _drawShockedFace(Canvas canvas, Paint p) {
    final x = Paint()
      ..color = const Color(0xFF0A2818)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // X eyes
    canvas.drawLine(const Offset(82, 80), const Offset(94, 92), x);
    canvas.drawLine(const Offset(94, 80), const Offset(82, 92), x);
    canvas.drawLine(const Offset(126, 80), const Offset(138, 92), x);
    canvas.drawLine(const Offset(138, 80), const Offset(126, 92), x);
    // O mouth
    canvas.drawOval(const Rect.fromLTWH(105, 101, 12, 14), p);
    // Exclamation
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '!',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFF8326D)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, const Offset(155, 60));
  }

  void _drawStarFace(Canvas canvas, Paint p) {
    // Star eyes
    for (final cx in [89.0, 133.0]) {
      final starPath = Path()
        ..moveTo(cx, 78)
        ..lineTo(cx + 2, 83)
        ..lineTo(cx + 5, 79)
        ..lineTo(cx + 3, 84)
        ..lineTo(cx + 6, 86)
        ..lineTo(cx + 1, 85)
        ..lineTo(cx, 90)
        ..lineTo(cx - 1, 85)
        ..lineTo(cx - 6, 86)
        ..lineTo(cx - 3, 84)
        ..lineTo(cx - 5, 79)
        ..lineTo(cx - 2, 83)
        ..close();
      canvas.drawPath(starPath, p);
    }
    // Big smile
    final smilePath = Path()
      ..moveTo(90, 100)
      ..quadraticBezierTo(111, 120, 132, 100)
      ..quadraticBezierTo(126, 110, 111, 112)
      ..quadraticBezierTo(96, 110, 90, 100)
      ..close();
    canvas.drawPath(smilePath, p);
  }

  void _drawControls(Canvas canvas) {
    // D-pad
    final dpadPaint = Paint()..color = const Color(0xFFFFD66B);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(75, 142, 6, 20), const Radius.circular(1.5)), dpadPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(68, 149, 20, 6), const Radius.circular(1.5)), dpadPaint);
    // A/B buttons
    canvas.drawCircle(const Offset(118, 152), 5, Paint()..color = const Color(0xFF5BD8FF));
    canvas.drawCircle(const Offset(135, 160), 5.5, Paint()..color = const Color(0xFFF8326D));
    canvas.drawCircle(const Offset(142, 146), 3.5, Paint()..color = const Color(0xFF22C796));
    // Speaker grille
    final speakerPaint = Paint()
      ..color = const Color(0x8C0A0118)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(Offset(155 + i * 3.0, 148), Offset(155 + i * 3.0, 166), speakerPaint);
    }
  }

  void _drawAntenna(Canvas canvas) {
    final antennaPaint = Paint()
      ..color = const Color(0xFF3F4750)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(111, 38), const Offset(111, 20), antennaPaint);

    final ballColor = switch (state) {
      MascotState.calm => const Color(0xFF5BFF8C),
      MascotState.alert => const Color(0xFFFFB347),
      MascotState.panicked => const Color(0xFFFF6B6B),
      MascotState.celebrating => const Color(0xFF5BFF8C),
    };
    final glowIntensity = 0.6 + 0.4 * animValue;
    canvas.drawCircle(const Offset(111, 16), 5, Paint()..color = ballColor.withValues(alpha: glowIntensity));
    canvas.drawCircle(
      const Offset(111, 16), 5,
      Paint()
        ..color = Color.lerp(ballColor, Colors.black, 0.3)!
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_MascotPainter old) =>
      old.state != state || old.animValue != animValue;
}

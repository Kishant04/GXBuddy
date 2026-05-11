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
  late final AnimationController _bodyCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _sparkleCtrl;

  @override
  void initState() {
    super.initState();
    _bodyCtrl = AnimationController(vsync: this);
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _sparkleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
    _startAnimations();
  }

  void _startAnimations() {
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
      case MascotState.emergency:
        _bodyCtrl
          ..duration = const Duration(milliseconds: 200)
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
        MascotState.emergency => const Color(0xFFFF0000),
        MascotState.celebrating => GXColors.celebrationLight,
      };

  Color get _screenColor => switch (widget.state) {
        MascotState.calm => const Color(0xFF5BFF8C),
        MascotState.alert => const Color(0xFFFFB347),
        MascotState.panicked => const Color(0xFFFF6B6B),
        MascotState.emergency => const Color(0xFFFF3030),
        MascotState.celebrating => const Color(0xFF5BFF8C),
      };

  Offset _bodyOffset(double t) => switch (widget.state) {
        MascotState.calm => Offset(0, -6 * sin(t * pi)),
        MascotState.alert => Offset(0, -3 * sin(t * pi)),
        MascotState.panicked =>
          Offset(4 * sin(t * 2 * pi), 2 * cos(t * 2 * pi)),
        MascotState.emergency =>
          Offset(6 * sin(t * 3 * pi), 3 * cos(t * 3 * pi)),
        MascotState.celebrating => Offset(0, -8 * sin(t * pi)),
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bodyCtrl, _glowCtrl, _sparkleCtrl]),
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _MascotPainter(
            state: widget.state,
            animValue: _bodyCtrl.value,
            glowValue: _glowCtrl.value,
            sparkleValue: _sparkleCtrl.value,
            glowColor: _glowColor,
            screenColor: _screenColor,
            bodyOffset: _bodyOffset(_bodyCtrl.value),
          ),
        );
      },
    );
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter({
    required this.state,
    required this.animValue,
    required this.glowValue,
    required this.sparkleValue,
    required this.glowColor,
    required this.screenColor,
    required this.bodyOffset,
  });

  final MascotState state;
  final double animValue;
  final double glowValue;
  final double sparkleValue;
  final Color glowColor;
  final Color screenColor;
  final Offset bodyOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 220;
    canvas.save();
    canvas.scale(scale);
    canvas.translate(bodyOffset.dx, bodyOffset.dy);

    _drawGlow(canvas);
    _drawLegs(canvas);
    _drawBody(canvas);
    _drawScreen(canvas);
    _drawFace(canvas);
    _drawControls(canvas);
    _drawAntenna(canvas);

    if (state == MascotState.celebrating) {
      _drawSparkles(canvas);
    }

    canvas.restore();
  }

  void _drawGlow(Canvas canvas) {
    final paint = Paint()
      ..color = glowColor.withValues(alpha: 0.15 + 0.1 * glowValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
    canvas.drawOval(const Rect.fromLTWH(40, 40, 140, 140), paint);
  }

  void _drawLegs(Canvas canvas) {
    final legPaint = Paint()
      ..color = const Color(0xFF2D353D)
      ..style = PaintingStyle.fill;
    // Left leg
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(75, 175, 20, 25), const Radius.circular(8)),
        legPaint);
    // Right leg
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(125, 175, 20, 25), const Radius.circular(8)),
        legPaint);
  }

  void _drawBody(Canvas canvas) {
    final bodyPaint = Paint()..color = const Color(0xFF3F4750);
    final rect = const Rect.fromLTWH(50, 45, 120, 145);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(32)), bodyPaint);

    // Side buttons (like volume/power)
    final detailPaint = Paint()..color = const Color(0xFF2D353D);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(42, 80, 8, 20), const Radius.circular(2)),
        detailPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(170, 100, 8, 30), const Radius.circular(2)),
        detailPaint);
  }

  void _drawScreen(Canvas canvas) {
    final screenPaint = Paint()..color = screenColor;
    final rect = const Rect.fromLTWH(62, 58, 96, 78);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(14)), screenPaint);

    // Inner shadow/bezel
    final bezel = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(14)), bezel);
  }

  void _drawFace(Canvas canvas) {
    final facePaint = Paint()..color = const Color(0xFF0A2818);

    switch (state) {
      case MascotState.calm:
        _drawHappyFace(canvas, facePaint);
      case MascotState.alert:
        _drawAlertFace(canvas, facePaint);
      case MascotState.panicked:
        _drawShockedFace(canvas, facePaint);
      case MascotState.emergency:
        _drawEmergencyFace(canvas, facePaint);
      case MascotState.celebrating:
        _drawStarFace(canvas, facePaint);
    }
  }

  void _drawHappyFace(Canvas canvas, Paint p) {
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(84, 78, 10, 14), const Radius.circular(2)),
        p);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(128, 78, 10, 14), const Radius.circular(2)),
        p);
    // Pupils
    canvas.drawCircle(const Offset(89, 83), 2.4, Paint()..color = Colors.white);
    canvas.drawCircle(
        const Offset(133, 83), 2.4, Paint()..color = Colors.white);
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

  void _drawAlertFace(Canvas canvas, Paint p) {
    // Brows
    final browPaint = Paint()..color = const Color(0xFF0A2818);
    canvas.save();
    canvas.translate(87, 75.5);
    canvas.rotate(-12 * pi / 180);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-7, -1.5, 14, 3), const Radius.circular(1.5)),
        browPaint);
    canvas.restore();
    canvas.save();
    canvas.translate(135, 75.5);
    canvas.rotate(12 * pi / 180);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-7, -1.5, 14, 3), const Radius.circular(1.5)),
        browPaint);
    canvas.restore();
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(84, 80, 10, 14), const Radius.circular(2)),
        p);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(128, 80, 10, 14), const Radius.circular(2)),
        p);
    // Flat concerned mouth
    final mouth = Paint()
      ..color = const Color(0xFF0A2818)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final mouthPath = Path()
      ..moveTo(95, 108)
      ..quadraticBezierTo(111, 102, 127, 108);
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
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFFF8326D)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, const Offset(155, 60));
  }

  void _drawEmergencyFace(Canvas canvas, Paint p) {
    final x = Paint()
      ..color = const Color(0xFF0A2818)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    // Massive X eyes
    canvas.drawLine(const Offset(80, 78), const Offset(98, 96), x);
    canvas.drawLine(const Offset(98, 78), const Offset(80, 96), x);
    canvas.drawLine(const Offset(122, 78), const Offset(140, 96), x);
    canvas.drawLine(const Offset(140, 78), const Offset(122, 96), x);
    // Giant O mouth
    canvas.drawOval(const Rect.fromLTWH(100, 100, 22, 26), p);
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
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(75, 142, 6, 20), const Radius.circular(1.5)),
        dpadPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(68, 149, 20, 6), const Radius.circular(1.5)),
        dpadPaint);
    // A/B buttons
    canvas.drawCircle(
        const Offset(118, 152), 5, Paint()..color = const Color(0xFF5BD8FF));
    canvas.drawCircle(
        const Offset(135, 160), 5.5, Paint()..color = const Color(0xFFF8326D));
    canvas.drawCircle(
        const Offset(142, 146), 3.5, Paint()..color = const Color(0xFF22C796));
    // Speaker grille
    final speakerPaint = Paint()
      ..color = const Color(0x8C0A0118)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
          Offset(155 + i * 3.0, 148), Offset(155 + i * 3.0, 166), speakerPaint);
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
      MascotState.emergency => const Color(0xFFFF0000),
      MascotState.celebrating => const Color(0xFF5BFF8C),
    };
    final glowIntensity = 0.6 + 0.4 * animValue;
    canvas.drawCircle(const Offset(111, 16), 5,
        Paint()..color = ballColor.withValues(alpha: glowIntensity));

    canvas.drawCircle(
      const Offset(111, 16),
      2.5,
      Paint()
        ..color = Color.lerp(ballColor, Colors.black, 0.3)!
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawSparkles(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    final r = Random(42);
    for (var i = 0; i < 6; i++) {
      final t = (sparkleValue + r.nextDouble()) % 1.0;
      final x = 40 + r.nextDouble() * 140;
      final y = 30 + r.nextDouble() * 160;
      final size = 2 + 4 * sin(t * pi);
      canvas.drawCircle(Offset(x, y), size, paint);
    }
  }

  @override
  bool shouldRepaint(_MascotPainter old) =>
      old.state != state || old.animValue != animValue;
}

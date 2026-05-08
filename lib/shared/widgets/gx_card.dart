import 'package:flutter/material.dart';
import '../../core/theme/gx_colors.dart';

class GXCard extends StatelessWidget {
  const GXCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.glowColor,
    this.accentBorderColor,
    this.gradient,
    this.onTap,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? glowColor;
  final Color? accentBorderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final borderColor = accentBorderColor ?? GXColors.border;
    final bg = gradient ??
        const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x0EFFFFFF), Color(0x05FFFFFF)],
        );

    final decoration = BoxDecoration(
      gradient: bg,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: glowColor != null
          ? [
              BoxShadow(color: glowColor!.withValues(alpha: 0.20), blurRadius: 40, spreadRadius: 0),
              BoxShadow(color: glowColor!.withValues(alpha: 0.12), blurRadius: 16, spreadRadius: 0),
              const BoxShadow(color: Color(0x66000000), blurRadius: 28, offset: Offset(0, 10)),
            ]
          : [const BoxShadow(color: Color(0x66000000), blurRadius: 28, offset: Offset(0, 10))],
    );

    Widget card = Container(
      margin: margin,
      decoration: decoration,
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 100),
          child: card,
        ),
      );
    }

    return card;
  }
}

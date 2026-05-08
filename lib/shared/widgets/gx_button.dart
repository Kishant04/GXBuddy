import 'package:flutter/material.dart';
import '../../core/theme/gx_colors.dart';

enum GXButtonVariant { primary, pink, ghost, danger, success, soft }
enum GXButtonSize { sm, md, lg }

class GXButton extends StatefulWidget {
  const GXButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = GXButtonVariant.primary,
    this.size = GXButtonSize.md,
    this.icon,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final GXButtonVariant variant;
  final GXButtonSize size;
  final Widget? icon;
  final bool expand;
  final bool loading;

  @override
  State<GXButton> createState() => _GXButtonState();
}

class _GXButtonState extends State<GXButton> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border, shadow) = _resolveStyle();
    final (padding, fontSize, radius) = _resolveSize();

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onPressed?.call(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: widget.expand ? double.infinity : null,
          padding: padding,
          decoration: BoxDecoration(
            gradient: bg,
            color: bg == null ? _flatColor() : null,
            borderRadius: BorderRadius.circular(radius),
            border: border,
            boxShadow: shadow,
          ),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              if (widget.loading)
                SizedBox(
                  width: fontSize, height: fontSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: fg,
                  ),
                )
              else
                Text(
                  widget.label,
                  style: TextStyle(
                    color: fg, fontSize: fontSize,
                    fontWeight: FontWeight.w600, letterSpacing: -0.01,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color? _flatColor() => switch (widget.variant) {
        GXButtonVariant.ghost => const Color(0x0DFFFFFF),
        GXButtonVariant.danger => const Color(0x1AEF4444),
        GXButtonVariant.success => const Color(0x1A22C796),
        GXButtonVariant.soft => const Color(0x1A771FFF),
        _ => null,
      };

  (Gradient?, Color, Border?, List<BoxShadow>?) _resolveStyle() =>
      switch (widget.variant) {
        GXButtonVariant.primary => (
            const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFA45EFF), GXColors.violet, Color(0xFF6A1ED9)],
            ),
            GXColors.textWhite,
            Border.all(color: const Color(0x30FFFFFF)),
            [BoxShadow(color: GXColors.violet.withValues(alpha: 0.40), blurRadius: 26, offset: const Offset(0, 10))],
          ),
        GXButtonVariant.pink => (
            const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF6B9C), GXColors.pink, GXColors.pinkDeep],
            ),
            GXColors.textWhite,
            Border.all(color: const Color(0x30FFFFFF)),
            [BoxShadow(color: GXColors.pink.withValues(alpha: 0.35), blurRadius: 26, offset: const Offset(0, 10))],
          ),
        GXButtonVariant.success => (
            null,
            GXColors.success,
            Border.all(color: GXColors.success.withValues(alpha: 0.35)),
            [BoxShadow(color: GXColors.success.withValues(alpha: 0.20), blurRadius: 18)],
          ),
        GXButtonVariant.soft => (
            null,
            const Color(0xFFD6BFFF),
            Border.all(color: GXColors.violet.withValues(alpha: 0.35)),
            null,
          ),
        GXButtonVariant.danger => (
            null,
            const Color(0xFFFF9999),
            Border.all(color: GXColors.danger.withValues(alpha: 0.35)),
            null,
          ),
        GXButtonVariant.ghost => (
            null,
            GXColors.textWhite,
            Border.all(color: const Color(0x1FFFFFFF)),
            null,
          ),
      };

  (EdgeInsets, double, double) _resolveSize() => switch (widget.size) {
        GXButtonSize.sm => (const EdgeInsets.symmetric(horizontal: 14, vertical: 9), 13, 11),
        GXButtonSize.md => (const EdgeInsets.symmetric(horizontal: 18, vertical: 14), 14.5, 14),
        GXButtonSize.lg => (const EdgeInsets.symmetric(horizontal: 22, vertical: 17), 16, 16),
      };
}

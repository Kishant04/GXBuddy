import 'package:flutter/material.dart';
import '../../../core/theme/gx_colors.dart';

class DemoTriggerPanel extends StatelessWidget {
  const DemoTriggerPanel({
    super.key,
    required this.onSpendFood,
    required this.onSpendShopping,
    required this.onReceiveSalary,
    required this.onSave,
  });

  final VoidCallback onSpendFood;
  final VoidCallback onSpendShopping;
  final VoidCallback onReceiveSalary;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _DemoButton(
            tint: GXColors.pink,
            icon: '🍔',
            label: 'Spend RM50',
            sub: 'Food',
            onTap: onSpendFood,
          ),
          _DemoButton(
            tint: GXColors.celebrationLight,
            icon: '🛍️',
            label: 'Spend RM100',
            sub: 'Shopping',
            onTap: onSpendShopping,
          ),
          _DemoButton(
            tint: GXColors.success,
            icon: '💸',
            label: 'Receive Salary',
            sub: 'RM1,200',
            onTap: onReceiveSalary,
          ),
          _DemoButton(
            tint: GXColors.celebration,
            icon: '💎',
            label: 'Save RM10',
            sub: 'To Emergency',
            onTap: onSave,
          ),
        ],
      );
}

class _DemoButton extends StatefulWidget {
  const _DemoButton({
    required this.tint,
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  final Color tint;
  final String icon;
  final String label;
  final String sub;
  final VoidCallback onTap;

  @override
  State<_DemoButton> createState() => _DemoButtonState();
}

class _DemoButtonState extends State<_DemoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.tint.withValues(alpha: 0.13),
                widget.tint.withValues(alpha: 0.03)
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.tint.withValues(alpha: 0.27)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: widget.tint.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: widget.tint.withValues(alpha: 0.33)),
                ),
                child: Center(
                    child: Text(widget.icon,
                        style: const TextStyle(fontSize: 17))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.label,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: GXColors.textWhite),
                        overflow: TextOverflow.ellipsis),
                    Text(widget.sub,
                        style: const TextStyle(
                            fontSize: 10.5, color: GXColors.textSoft)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

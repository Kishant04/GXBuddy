import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/gx_colors.dart';
import '../../../models/autopilot_rule.dart';
import '../../../shared/widgets/gx_button.dart';
import '../pockets_controller.dart';
import '../../home/home_controller.dart';

class AutopilotConfigSheet extends ConsumerWidget {
  const AutopilotConfigSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rule = ref.watch(autopilotEditorProvider);
    final notifier = ref.read(autopilotEditorProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFF1F0A4D), Color(0xFF0E0228), Color(0xFF08001A)],
          stops: [0.0, 0.75, 1.0],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(20, 18, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0x30FFFFFF), borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '· SALARY AUTOPILOT ·',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFD6BFFF), letterSpacing: 0.18),
            ),
            const SizedBox(height: 6),
            const Text(
              'Set it once. Save forever.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: GXColors.textWhite, letterSpacing: -0.03),
            ),
            const SizedBox(height: 4),
            const Text(
              'GXBuddy splits your salary into pockets the moment it lands.',
              style: TextStyle(fontSize: 12.5, color: GXColors.textSoft, height: 1.5),
            ),
            const SizedBox(height: 20),
            // Threshold
            _Section(
              label: 'Salary detection threshold',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('RM', style: TextStyle(fontSize: 13, color: GXColors.textSoft)),
                      const SizedBox(width: 4),
                      Text(
                        rule.threshold.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: GXColors.textWhite, letterSpacing: -0.025),
                      ),
                    ],
                  ),
                  Slider(
                    value: rule.threshold,
                    min: 200, max: 3000, divisions: 28,
                    activeColor: GXColors.violet,
                    inactiveColor: const Color(0x1AFFFFFF),
                    onChanged: notifier.setThreshold,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('RM200', style: TextStyle(fontSize: 10.5, color: GXColors.textMute)),
                      Text('RM3,000', style: TextStyle(fontSize: 10.5, color: GXColors.textMute)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trigger autopilot for credits above RM${rule.threshold.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 11, color: GXColors.textMute),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Income type
            _Section(
              label: 'Income type',
              child: _SegmentControl<IncomeType>(
                options: const [
                  _Opt(IncomeType.monthly, '💼', 'Monthly salary'),
                  _Opt(IncomeType.gig, '🛵', 'Gig income'),
                ],
                value: rule.incomeType,
                onChange: notifier.setIncomeType,
              ),
            ),
            const SizedBox(height: 14),
            // Split rule
            _Section(
              label: 'Split rule',
              child: _SegmentControl<SplitRuleType>(
                options: const [
                  _Opt(SplitRuleType.fixed, '💵', 'Fixed RM'),
                  _Opt(SplitRuleType.percent, '%', 'Percentage'),
                ],
                value: rule.splitRule,
                onChange: notifier.setSplitRule,
              ),
            ),
            const SizedBox(height: 14),
            // Allocations
            _Section(
              label: 'Pocket allocation',
              child: Column(
                children: rule.allocations.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _AllocRow(alloc: a, splitRule: rule.splitRule),
                )).toList(),
              ),
            ),
            const SizedBox(height: 20),
            GXButton(
              label: 'Save rule',
              onPressed: () {
                ref.read(appStateProvider.notifier).updateAutopilot(rule);
                Navigator.of(context).pop();
              },
              variant: GXButtonVariant.primary,
              size: GXButtonSize.lg,
              expand: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: GXColors.textSoft, letterSpacing: 0.14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0x09FFFFFF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: GXColors.border),
            ),
            child: child,
          ),
        ],
      );
}

class _Opt<T> {
  const _Opt(this.value, this.icon, this.label);
  final T value;
  final String icon;
  final String label;
}

class _SegmentControl<T> extends StatelessWidget {
  const _SegmentControl({required this.options, required this.value, required this.onChange});
  final List<_Opt<T>> options;
  final T value;
  final ValueChanged<T> onChange;

  @override
  Widget build(BuildContext context) => Row(
        children: options.map((o) {
          final active = o.value == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChange(o.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Color(0xFFA45EFF), GXColors.violetDeep],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: active
                      ? [BoxShadow(color: GXColors.violet.withValues(alpha: 0.40), blurRadius: 14)]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(o.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      o.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: active ? GXColors.textWhite : GXColors.textSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
}

class _AllocRow extends StatelessWidget {
  const _AllocRow({required this.alloc, required this.splitRule});
  final PocketAllocation alloc;
  final SplitRuleType splitRule;

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('FF${alloc.colorHex.replaceAll('#', '')}', radix: 16));
    final suffix = splitRule == SplitRuleType.percent ? '%' : '';

    return Row(
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: color.withValues(alpha: 0.33)),
          ),
          child: Center(child: Text(alloc.icon, style: const TextStyle(fontSize: 14))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(alloc.pocketName,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GXColors.textWhite)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.33)),
          ),
          child: Text(
            '${alloc.value.toStringAsFixed(0)}$suffix',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: color),
          ),
        ),
      ],
    );
  }
}

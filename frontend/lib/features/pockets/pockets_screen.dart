import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/gx_colors.dart';
import '../../models/autopilot_rule.dart';
import '../../models/pocket_model.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/gx_button.dart';
import '../../shared/widgets/gx_card.dart';
import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/pocket_card.dart';
import 'pockets_controller.dart';
import 'widgets/autopilot_config_sheet.dart';

class PocketsScreen extends ConsumerWidget {
  const PocketsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pocketsAsync = ref.watch(pocketsAsyncProvider);
    final autopilotAsync = ref.watch(autopilotProvider);

    return RefreshIndicator(
      color: GXColors.violet,
      backgroundColor: const Color(0xFF14053A),
      onRefresh: () async {
        await ref.read(pocketsAsyncProvider.notifier).refresh();
        await ref.read(autopilotProvider.notifier).refresh();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 60, 18, 130),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                pocketsAsync.when(
                  loading: () =>
                      const SizedBox(height: 300, child: LoadingState()),
                  error: (e, _) => ErrorState(
                    message: 'Could not load pockets.',
                    onRetry: () =>
                        ref.read(pocketsAsyncProvider.notifier).refresh(),
                  ),
                  data: (pockets) => _buildContent(
                    context,
                    ref,
                    pockets,
                    autopilotAsync.valueOrNull ??
                        const AutopilotRule(
                            threshold: 800,
                            incomeType: IncomeType.monthly,
                            splitRule: SplitRuleType.percent,
                            allocations: []),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<PocketModel> pockets,
    AutopilotRule autopilot,
  ) {
    final total = pockets.fold(0.0, (s, p) => s + p.balance);
    final lastSplit = autopilot.lastSplitAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total saved',
                style: TextStyle(fontSize: 13, color: GXColors.textSoft)),
            const SizedBox(height: 2),
            Text(
              'RM${total.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: GXColors.textWhite,
                  letterSpacing: -0.03),
            ),
            if (lastSplit > 0) ...[
              const SizedBox(height: 2),
              Text(
                '↑ RM${lastSplit.toStringAsFixed(0)} from last salary autopilot',
                style: const TextStyle(fontSize: 12, color: GXColors.success),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        // Autopilot card
        _AutopilotCard(
          threshold: autopilot.threshold,
          allocations: autopilot.allocations,
          onConfigure: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AutopilotConfigSheet(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Your pockets',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: GXColors.textWhite,
                    letterSpacing: -0.02)),
            GestureDetector(
              onTap: () => _showCreatePocketDialog(context, ref),
              child: const Text('+ New',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: GXColors.violet)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...pockets.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PocketCard(pocket: p),
            )),
      ],
    );
  }

  void _showCreatePocketDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final splitCtrl = TextEditingController(text: '0');
    var splitType = 'percent';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1F0A4A),
          title: const Text('Create New Pocket',
              style: TextStyle(color: GXColors.textWhite)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: GXColors.textWhite),
                  decoration: const InputDecoration(
                    labelText: 'Pocket Name',
                    labelStyle: TextStyle(color: GXColors.textSoft),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: GXColors.border)),
                  ),
                ),
                TextField(
                  controller: targetCtrl,
                  style: const TextStyle(color: GXColors.textWhite),
                  decoration: const InputDecoration(
                    labelText: 'Target Amount (RM)',
                    labelStyle: TextStyle(color: GXColors.textSoft),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: GXColors.border)),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Autopilot Split Rule',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: GXColors.textSoft)),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: splitType,
                        dropdownColor: const Color(0xFF1F0A4A),
                        style: const TextStyle(color: GXColors.textWhite),
                        items: const [
                          DropdownMenuItem(value: 'percent', child: Text('%')),
                          DropdownMenuItem(value: 'fixed', child: Text('RM')),
                        ],
                        onChanged: (v) =>
                            setDialogState(() => splitType = v ?? 'percent'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: splitCtrl,
                        style: const TextStyle(color: GXColors.textWhite),
                        decoration: const InputDecoration(
                          labelText: 'Value',
                          labelStyle: TextStyle(color: GXColors.textSoft),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: GXColors.textSoft)),
            ),
            TextButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final target = double.tryParse(targetCtrl.text.trim()) ?? 0;
                final splitVal = double.tryParse(splitCtrl.text.trim()) ?? 0;

                if (name.isEmpty) {
                  return;
                }
                if (target <= 0) {
                  return;
                }
                if (splitType == 'percent' &&
                    (splitVal < 0 || splitVal > 100)) {
                  return;
                }

                final ok = await ref
                    .read(pocketsAsyncProvider.notifier)
                    .createPocket(
                      name: name,
                      target: target,
                      splitRule: SplitRule(type: splitType, value: splitVal),
                    );

                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to create pocket')),
                    );
                  }
                }
              },
              child: const Text('Create',
                  style: TextStyle(color: GXColors.violetLight)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AutopilotCard extends StatelessWidget {
  const _AutopilotCard({
    required this.threshold,
    required this.allocations,
    required this.onConfigure,
  });

  final double threshold;
  final List<PocketAllocation> allocations;
  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context) => GXCard(
        glowColor: GXColors.violet,
        padding: const EdgeInsets.all(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GXColors.violet.withValues(alpha: 0.15),
            const Color(0x05FFFFFF)
          ],
        ),
        accentBorderColor: GXColors.violet.withValues(alpha: 0.27),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [GXColors.violetLight, GXColors.violetDeep]),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Salary Autopilot',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: GXColors.textWhite)),
                      Text(
                        'Active · triggers above RM${threshold.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 11.5, color: GXColors.textSoft),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 38,
                  height: 22,
                  decoration: BoxDecoration(
                    color: GXColors.violet,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [
                      BoxShadow(
                          color: GXColors.violet.withValues(alpha: 0.55),
                          blurRadius: 12)
                    ],
                  ),
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: CircleAvatar(
                          radius: 9, backgroundColor: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            if (allocations.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: allocations.map<Widget>((a) {
                  final color = Color(int.parse(
                      'FF${a.colorHex.replaceAll('#', '')}',
                      radix: 16));
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: color.withValues(alpha: 0.27)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${a.value.toStringAsFixed(0)}%',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: color,
                                letterSpacing: -0.02),
                          ),
                          Text(a.pocketName,
                              style: const TextStyle(
                                  fontSize: 10, color: GXColors.textSoft),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            GXButton(
              label: 'Configure Autopilot',
              onPressed: onConfigure,
              variant: GXButtonVariant.soft,
              expand: true,
            ),
          ],
        ),
      );
}

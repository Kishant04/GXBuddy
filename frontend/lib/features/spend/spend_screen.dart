import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/gx_colors.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/transaction_tile.dart';
import 'spend_controller.dart';

class SpendScreen extends ConsumerWidget {
  const SpendScreen({super.key});

  static const _filters = [
    'All',
    'Risky',
    'Essential',
    'Income',
    'Food',
    'Transport',
    'Shopping',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider);
    final filter = ref.watch(selectedFilterProvider);
    final filtered = ref.watch(filteredTransactionsProvider);

    // Total spent: sum of non-income transactions in the live list.
    final allTx = txAsync.valueOrNull ?? [];
    final totalSpent =
        allTx.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);

    return RefreshIndicator(
      color: GXColors.violet,
      backgroundColor: const Color(0xFF14053A),
      onRefresh: () => ref.read(transactionsProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 60, 18, 130),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('This week',
                        style:
                            TextStyle(fontSize: 13, color: GXColors.textSoft)),
                    const SizedBox(height: 2),
                    Text(
                      'RM${totalSpent.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: GXColors.textWhite,
                        letterSpacing: -0.03,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Comparison to last week comes from backend in future.
                  ],
                ),
                const SizedBox(height: 16),
                // AI insight card — powered by Ilmu GLM
                _AiInsightCard(
                  insight: ref.watch(spendInsightProvider).valueOrNull,
                ),
                const SizedBox(height: 14),
                // Filter chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => _FilterChip(
                      label: _filters[i],
                      selected: _filters[i] == filter,
                      onTap: () => ref
                          .read(selectedFilterProvider.notifier)
                          .state = _filters[i],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Recent activity',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: GXColors.textWhite,
                        letterSpacing: -0.02)),
                const SizedBox(height: 12),
                // Transactions section
                txAsync.when(
                  loading: () =>
                      const SizedBox(height: 160, child: LoadingState()),
                  error: (e, _) => ErrorState(
                    message: 'Could not load transactions.',
                    onRetry: () =>
                        ref.read(transactionsProvider.notifier).refresh(),
                  ),
                  data: (_) => filtered.isEmpty
                      ? const EmptyState(
                          message: 'No transactions here.', emoji: '✨')
                      : Column(
                          children: filtered
                              .map((tx) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: TransactionTile(tx: tx),
                                  ))
                              .toList(),
                        ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiInsightCard extends StatelessWidget {
  const _AiInsightCard({this.insight});

  /// Live insight text from the backend. When null, shows a loading state.
  final String? insight;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x1FA855F7), Color(0x05FFFFFF)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x66A855F7)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x66000000), blurRadius: 28, offset: Offset(0, 10))
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [GXColors.celebrationLight, GXColors.celebration],
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI INSIGHT',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFC9A8FF),
                      letterSpacing: 0.12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Show live GLM insight or a skeleton placeholder
            if (insight == null || insight!.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              )
            else
              Text(
                insight!,
                style: const TextStyle(
                    fontSize: 13.5,
                    color: GXColors.textWhite,
                    height: 1.5,
                    fontWeight: FontWeight.w400),
              ),
          ],
        ),
      );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? GXColors.violet : const Color(0x0DFFFFFF),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
                color: selected ? Colors.transparent : const Color(0x14FFFFFF)),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: GXColors.violet.withValues(alpha: 0.35),
                        blurRadius: 12)
                  ]
                : null,
          ),
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: GXColors.textWhite),
          ),
        ),
      );
}

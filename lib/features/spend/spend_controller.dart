import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transaction_model.dart';
import '../../providers/repository_provider.dart';
import '../../providers/user_id_provider.dart';

/// AI-generated spend insight from the backend (Ilmu GLM).
final spendInsightProvider = FutureProvider<String>((ref) async {
  final userId = ref.watch(resolvedUserIdProvider);
  if (userId == null) return '';
  try {
    return await ref.read(repositoryProvider).getSpendInsight(userId: userId);
  } catch (_) {
    return '';
  }
});

// ─── Async transactions ───────────────────────────────────────────────────────

class TransactionsNotifier extends AsyncNotifier<List<TransactionModel>> {
  @override
  Future<List<TransactionModel>> build() => _load();

  Future<List<TransactionModel>> _load() async {
    final userId = ref.read(resolvedUserIdProvider);
    if (userId == null) return [];
    return ref
        .read(repositoryProvider)
        .getTransactions(userId: userId, limit: 50);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<TransactionModel>>(
  TransactionsNotifier.new,
);

// ─── Filter chip ──────────────────────────────────────────────────────────────

final selectedFilterProvider = StateProvider<String>((ref) => 'All');

// ─── Derived filtered list ────────────────────────────────────────────────────

final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final filter = ref.watch(selectedFilterProvider);
  // Prefer live repository data; fall back to empty list while loading.
  final transactions = ref.watch(transactionsProvider).valueOrNull ?? [];

  if (filter == 'All') return transactions;

  return transactions.where((tx) {
    return switch (filter) {
      'Risky' => tx.riskLabel == 'Risky',
      'Essential' => tx.riskLabel == 'Essential',
      'Income' => tx.isIncome,
      'Food' => tx.category.toLowerCase() == 'food',
      'Transport' => tx.category.toLowerCase() == 'transport',
      'Shopping' => tx.category.toLowerCase() == 'shopping',
      'Lifestyle' => tx.category.toLowerCase() == 'lifestyle',
      _ => true,
    };
  }).toList();
});

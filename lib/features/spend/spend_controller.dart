import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transaction.dart';
import '../home/home_controller.dart';

final selectedFilterProvider = StateProvider<String>((ref) => 'All');

final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final filter = ref.watch(selectedFilterProvider);
  final transactions = ref.watch(appStateProvider).transactions;

  if (filter == 'All') return transactions;

  return transactions.where((tx) {
    return switch (filter) {
      'Risky' => tx.riskLabel == 'Risky',
      'Essential' => tx.riskLabel == 'Essential',
      'Income' => tx.isIncome,
      'Food' => tx.category == 'Food',
      'Transport' => tx.category == 'Transport',
      'Shopping' => tx.category == 'Shopping',
      'Lifestyle' => tx.category == 'Lifestyle',
      _ => true,
    };
  }).toList();
});

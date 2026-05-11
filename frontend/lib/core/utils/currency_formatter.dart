import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static final _fmt =
      NumberFormat.currency(locale: 'ms_MY', symbol: 'RM', decimalDigits: 2);
  static final _compact = NumberFormat.compactCurrency(
      locale: 'ms_MY', symbol: 'RM', decimalDigits: 1);

  static String format(double amount) => _fmt.format(amount);
  static String compact(double amount) => _compact.format(amount);

  static String shortAmount(double amount) {
    if (amount >= 1000) return 'RM${(amount / 1000).toStringAsFixed(1)}k';
    return 'RM${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
  }

  static String formatNoSymbol(double amount) =>
      NumberFormat('#,##0.00').format(amount);
}

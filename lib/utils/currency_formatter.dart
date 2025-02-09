import 'package:intl/intl.dart';

import '../models/transaction.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }

  static String formatWithSign(double amount, TransactionType type) {
    final formatted = format(amount.abs());
    return type == TransactionType.income ? '+$formatted' : '-$formatted';
  }
}
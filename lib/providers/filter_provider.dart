import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_tracker/models/transaction.dart';

import 'transaction_provider.dart';

final dateFilterProvider = StateProvider<DateTimeRange?>((ref) => null);
final typeFilterProvider = StateProvider<TransactionType?>((ref) => null);
final showAllTimeProvider = StateProvider<bool>((ref) => true);

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionProvider);
  final dateRange = ref.watch(dateFilterProvider);
  final showAllTime = ref.watch(showAllTimeProvider);
  final transactionType = ref.watch(typeFilterProvider);

  return transactions.where((t) {
    final dateValid = showAllTime ||
        dateRange == null ||
        (t.date.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(dateRange.end.add(const Duration(days: 1))));
    final typeValid = transactionType == null || t.type == transactionType;
    return dateValid && typeValid;
  }).toList();
});

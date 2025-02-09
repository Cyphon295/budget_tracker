import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:budget_tracker/models/transaction.dart';

final transactionProvider = StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  return TransactionNotifier();
});

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super(Hive.box<Transaction>('transactions').values.toList());

  void addTransaction(Transaction transaction) {
    Hive.box<Transaction>('transactions').add(transaction);
    state = [...state, transaction];
  }

  void deleteTransaction(String id) {
    final index = state.indexWhere((t) => t.id == id);
    if (index != -1) {
      Hive.box<Transaction>('transactions').deleteAt(index);
      state = state.where((t) => t.id != id).toList();
    }
  }
}
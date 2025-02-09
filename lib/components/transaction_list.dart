// lib/components/transaction_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budget_tracker/models/transaction.dart';

import '../utils/currency_formatter.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(String) onDelete;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions yet'));
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Dismissible(
          key: Key(transaction.id),
          background: Container(color: Colors.red),
          onDismissed: (direction) => onDelete(transaction.id),
          child: ListTile(
            title: Text(transaction.title),
            subtitle: Text(
              DateFormat.yMd().add_jm().format(transaction.date),
            ),
            trailing: Text(
              CurrencyFormatter.formatWithSign(
                transaction.amount,
                transaction.type,
              ),
              style: TextStyle(
                color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:budget_tracker/providers/transaction_provider.dart';

class ExportButton extends ConsumerWidget {
  const ExportButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.upload),
      onPressed: () async {
        final transactions = ref.read(transactionProvider);
        if (transactions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No transactions to export')),
          );
          return;
        }

        final csv = const ListToCsvConverter().convert([
          ['Date', 'Title', 'Amount', 'Type', 'Category'],
          ...transactions.map((t) => [
                DateFormat('yyyy-MM-dd').format(t.date),
                t.title,
                t.amount.toString(),
                t.type.toString().split('.').last,
                t.category,
              ]),
        ]);

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/transactions.csv');
        await file.writeAsString(csv);

        await Share.shareXFiles([XFile(file.path)]);
      },
    );
  }
}
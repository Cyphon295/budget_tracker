import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_tracker/components/financial_chart.dart';
import 'package:budget_tracker/components/transaction_list.dart';
import 'package:budget_tracker/components/ad_banner.dart';
import 'package:budget_tracker/screens/add_transaction.dart';
import 'package:budget_tracker/screens/category_manager.dart';
import 'package:intl/intl.dart';

import '../components/export_button.dart';
import '../models/chart_period.dart';
import '../models/chart_type.dart';
import '../providers/category_provider.dart';
import '../providers/chart_period_provider.dart';
import '../providers/chart_type_provider.dart';
import '../providers/filter_provider.dart';
import '../providers/transaction_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);
    debugPrint('Categories: ${categories.length}');

    if (categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
        actions: [
          PopupMenuButton<ChartPeriod>(
            icon: const Icon(Icons.bar_chart),
            onSelected: (period) => ref.read(chartPeriodProvider.notifier).state = period,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ChartPeriod.weekly,
                child: Text('Weekly View'),
              ),
              const PopupMenuItem(
                value: ChartPeriod.monthly,
                child: Text('Monthly View'),
              ),
              const PopupMenuItem(
                value: ChartPeriod.yearly,
                child: Text('Yearly View'),
              ),
            ],
          ),
          PopupMenuButton<ChartType>(
            icon: const Icon(Icons.bar_chart),
            onSelected: (type) => ref.read(chartTypeProvider.notifier).state = type,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ChartType.bar,
                child: Text('Bar Chart'),
              ),
              const PopupMenuItem(
                value: ChartType.line,
                child: Text('Line Chart'),
              ),
              const PopupMenuItem(
                value: ChartType.pie,
                child: Text('Pie Chart'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CategoryManagerScreen()),
            ),
          ),
          const ExportButton(),
        ],
      ),
      body: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final showAllTime = ref.watch(showAllTimeProvider);
              final dateRange = ref.watch(dateFilterProvider);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    if (!showAllTime && dateRange != null)
                      Expanded(
                        child: Text(
                          'Showing ${DateFormat('MMM dd, yyyy').format(dateRange.start)}'
                          ' - ${DateFormat('MMM dd, yyyy').format(dateRange.end)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    if (showAllTime)
                      Expanded(
                        child: Text(
                          'Showing All Time',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.filter_alt),
                      onPressed: () => _showFilterDialog(context, ref),
                      tooltip: 'Filter',
                    ),
                    if (!showAllTime)
                      IconButton(
                        icon: const Icon(Icons.filter_alt_off),
                        onPressed: () {
                          ref.read(dateFilterProvider.notifier).state = null;
                          ref.read(showAllTimeProvider.notifier).state = true;
                        },
                        tooltip: 'Clear Filters',
                      ),
                  ],
                ),
              );
            },
          ),
          FinancialChart(
            transactions: ref.watch(filteredTransactionsProvider),
          ),
          Expanded(
            child: TransactionList(
              transactions: ref.watch(filteredTransactionsProvider),
              onDelete: (id) => ref.read(transactionProvider.notifier).deleteTransaction(id),
            ),
          ),
          const AdBanner(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) async {
    final currentRange = ref.read(dateFilterProvider);
    final showAllTime = ref.read(showAllTimeProvider);

    await showDialog(
      context: context,
      builder: (context) {
        DateTime startDate = currentRange?.start ?? DateTime.now();
        DateTime endDate = currentRange?.end ?? DateTime.now();
        bool localShowAllTime = showAllTime;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Date Range'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('Show All Time'),
                      value: localShowAllTime,
                      onChanged: (value) {
                        setState(() {
                          localShowAllTime = value;
                          if (value) {
                            // Clear date range when showing all time
                            ref.read(dateFilterProvider.notifier).state = null;
                          }
                        });
                      },
                    ),
                    if (!localShowAllTime)
                      Column(
                        children: [
                          ListTile(
                            title: const Text('Start Date'),
                            subtitle: Text(DateFormat('MMM dd, yyyy').format(startDate)),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: startDate,
                                firstDate: DateTime(2000),
                                lastDate: endDate,
                              );
                              if (date != null) {
                                setState(() => startDate = date);
                              }
                            },
                          ),
                          ListTile(
                            title: const Text('End Date'),
                            subtitle: Text(DateFormat('MMM dd, yyyy').format(endDate)),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: endDate,
                                firstDate: startDate,
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() => endDate = date);
                              }
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (!localShowAllTime) {
                      ref.read(dateFilterProvider.notifier).state = DateTimeRange(start: startDate, end: endDate);
                    }
                    ref.read(showAllTimeProvider.notifier).state = localShowAllTime;
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

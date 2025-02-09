import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:budget_tracker/providers/chart_period_provider.dart';
import 'package:budget_tracker/providers/chart_type_provider.dart';

import '../models/chart_period.dart';
import '../models/chart_type.dart';
import '../models/transaction.dart';
import '../utils/currency_formatter.dart';

class FinancialChart extends ConsumerWidget {
  final List<Transaction> transactions;

  const FinancialChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartType = ref.watch(chartTypeProvider);
    final chartPeriod = ref.watch(chartPeriodProvider);

    final chartData = _calculateChartData(transactions, chartPeriod);
    if (chartData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No data available')),
      );
    }

    return SizedBox(
      height: 200,
      child: _buildChart(chartType, chartData, chartPeriod),
    );
  }

  Map<DateTime, double> _calculateChartData(List<Transaction> transactions, ChartPeriod period) {
    final Map<DateTime, double> data = {};

    for (final t in transactions) {
      DateTime key;
      switch (period) {
        case ChartPeriod.weekly:
          key = _startOfWeek(t.date);
        case ChartPeriod.monthly:
          key = DateTime(t.date.year, t.date.month);
        case ChartPeriod.yearly:
          key = DateTime(t.date.year);
      }

      final amount = t.type == TransactionType.income ? t.amount : -t.amount;
      data.update(key, (value) => value + amount, ifAbsent: () => amount);
    }

    return data;
  }

  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Widget _buildChart(ChartType type, Map<DateTime, double> data, ChartPeriod period) {
    switch (type) {
      case ChartType.bar:
        return BarChart(
          BarChartData(
            barGroups: _buildChartData(data),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final date = _getDateFromValue(value, period);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(_formatDate(date, period)),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
        );
      case ChartType.line:
        return LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: data.entries.map((e) {
                  return FlSpot(_getValueFromDate(e.key, period), e.value);
                }).toList(),
                isCurved: true,
                color: Colors.blue,
                barWidth: 4,
                belowBarData: BarAreaData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final date = _getDateFromValue(value, period);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(_formatDate(date, period)),
                    );
                  },
                ),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
          ),
        );
      case ChartType.pie:
        final categoryData = _calculateCategoryData(transactions);
        return PieChart(
          PieChartData(
            sections: categoryData.entries.map((entry) {
              return PieChartSectionData(
                value: entry.value.abs(),
                color: _getCategoryColor(entry.key),
                title: '${entry.key}\n${CurrencyFormatter.format(entry.value)}',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
            sectionsSpace: 2,
            centerSpaceRadius: 40,
          ),
        );
    }
  }

  Map<String, double> _calculateCategoryData(List<Transaction> transactions) {
    final Map<String, double> categoryData = {};

    for (final t in transactions) {
      final amount = t.type == TransactionType.income ? t.amount : -t.amount;
      categoryData.update(
        t.category,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
    }

    return categoryData;
  }

  String _formatDate(DateTime date, ChartPeriod period) {
    switch (period) {
      case ChartPeriod.weekly:
        return DateFormat('MMM dd').format(date);
      case ChartPeriod.monthly:
        return DateFormat('MMM').format(date);
      case ChartPeriod.yearly:
        return DateFormat('yyyy').format(date);
    }
  }

  DateTime _getDateFromValue(double value, ChartPeriod period) {
    switch (period) {
      case ChartPeriod.weekly:
        return DateTime.now().subtract(Duration(days: value.toInt() * 7));
      case ChartPeriod.monthly:
        return DateTime(0, value.toInt());
      case ChartPeriod.yearly:
        return DateTime(value.toInt());
    }
  }

  double _getValueFromDate(DateTime date, ChartPeriod period) {
    switch (period) {
      case ChartPeriod.weekly:
        return date.difference(_startOfWeek(DateTime.now())).inDays / 7;
      case ChartPeriod.monthly:
        return date.month.toDouble();
      case ChartPeriod.yearly:
        return date.year.toDouble();
    }
  }

  List<BarChartGroupData> _buildChartData(Map<DateTime, double> monthlyData) {
    return monthlyData.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key.month,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: entry.value >= 0 ? Colors.green : Colors.red,
            width: 16,
          )
        ],
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    // You can customize this to return specific colors for categories
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    return colors[category.hashCode % colors.length];
  }
}

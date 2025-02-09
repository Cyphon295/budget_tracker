import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_tracker/models/chart_period.dart';

final chartPeriodProvider = StateProvider<ChartPeriod>((ref) => ChartPeriod.monthly);
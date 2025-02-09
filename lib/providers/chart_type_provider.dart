import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_tracker/models/chart_type.dart';

final chartTypeProvider = StateProvider<ChartType>((ref) => ChartType.bar);
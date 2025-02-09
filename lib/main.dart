import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:budget_tracker/models/transaction.dart';
import 'package:budget_tracker/models/category.dart';
import 'package:budget_tracker/screens/home_screen.dart';

import 'components/app_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(TransactionAdapter());
  }
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TransactionTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(CategoryAdapter());
  }

  debugPrint('TransactionAdapter registered: ${Hive.isAdapterRegistered(0)}');
  debugPrint('TransactionTypeAdapter registered: ${Hive.isAdapterRegistered(1)}');
  debugPrint('CategoryAdapter registered: ${Hive.isAdapterRegistered(2)}');

  // Clear existing data (only for development/testing)
  await Hive.deleteBoxFromDisk('categories');
  await Hive.deleteBoxFromDisk('transactions');

  // Open boxes
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Category>('categories');

  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AppInitializer(
        child: HomeScreen(),
      ),
    );
  }
}

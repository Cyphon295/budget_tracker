import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budget_tracker/providers/category_provider.dart';

class AppInitializer extends ConsumerWidget {
  final Widget child;
  
  const AppInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);
    final categoryNotifier = ref.read(categoryProvider.notifier);

    if (categories.isEmpty) {
      // Load categories if they're empty
      Future.microtask(() => categoryNotifier.loadCategories());
      
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    
    return child;
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:budget_tracker/models/category.dart';

import '../models/transaction.dart';

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  return CategoryNotifier();
});

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]);

  Future<void> loadCategories() async {
    try {
      final box = Hive.box<Category>('categories');
      
      if (box.isEmpty) {
        final defaultCategories = [
          Category(name: 'Salary', type: TransactionType.income),
          Category(name: 'Investment', type: TransactionType.income),
          Category(name: 'Gift', type: TransactionType.income),
          Category(name: 'Food', type: TransactionType.expense),
          Category(name: 'Transport', type: TransactionType.expense),
          Category(name: 'Entertainment', type: TransactionType.expense),
          Category(name: 'Utilities', type: TransactionType.expense),
          Category(name: 'Rent', type: TransactionType.expense),
        ];
        
        await box.addAll(defaultCategories);
        state = defaultCategories;
      } else {
        state = box.values.toList();
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
      state = [];
    }
  }

  void addCategory(Category category) {
    Hive.box<Category>('categories').add(category);
    state = [...state, category];
  }

  void deleteCategory(Category category) {
    final index = state.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      Hive.box<Category>('categories').deleteAt(index);
      state = state.where((c) => c.id != category.id).toList();
    }
  }
}

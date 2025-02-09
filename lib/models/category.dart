import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'transaction.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class Category {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final TransactionType type;

  Category({
    String? id,
    required this.name,
    required this.type,
  }) : id = id ?? const Uuid().v4();
}
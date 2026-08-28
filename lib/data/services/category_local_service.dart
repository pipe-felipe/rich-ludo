import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../config/database_config.dart';
import '../../domain/model/custom_category.dart';
import '../../domain/model/custom_category_mapper.dart';
import '../../utils/result.dart';
import '../local/database/database_helper.dart';
import 'category_service.dart';

class CategoryLocalService implements CategoryService {
  final DatabaseHelper _databaseHelper;

  CategoryLocalService({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<Database> get database => _databaseHelper.database;

  @override
  Future<Result<List<CustomCategory>>> getAllCategories() async {
    try {
      final db = await database;
      final maps = await db.query(
        DatabaseConfig.categoriesTableName,
        orderBy: 'name ASC',
      );
      final categories = maps.map(CustomCategoryMapper.fromMap).toList();
      return Result.ok(categories);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<int>> insertCategory(CustomCategory category) async {
    try {
      final db = await database;
      final id = await db.insert(
        DatabaseConfig.categoriesTableName,
        CustomCategoryMapper.toMap(category),
      );
      return Result.ok(id);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<int>> deleteCategory(int id) async {
    try {
      final db = await database;
      final count = await db.delete(
        DatabaseConfig.categoriesTableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      return Result.ok(count);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}

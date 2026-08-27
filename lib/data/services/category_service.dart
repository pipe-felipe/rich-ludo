import 'dart:async';
import '../../domain/model/custom_category.dart';
import '../../utils/result.dart';

abstract class CategoryService {
  Future<Result<List<CustomCategory>>> getAllCategories();

  Future<Result<int>> insertCategory(CustomCategory category);

  Future<Result<int>> deleteCategory(int id);
}

import '../model/custom_category.dart';
import '../../utils/result.dart';

abstract class CategoryRepository {
  Future<Result<List<CustomCategory>>> getCategories();

  Future<Result<int>> createCategory(CustomCategory category);

  Future<Result<int>> deleteCategory(int id);
}

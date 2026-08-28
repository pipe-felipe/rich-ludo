import '../../domain/model/custom_category.dart';
import '../../domain/repository/category_repository.dart';
import '../../utils/result.dart';
import '../services/category_service.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryService _service;

  CategoryRepositoryImpl({required CategoryService service})
    : _service = service;

  @override
  Future<Result<List<CustomCategory>>> getCategories() {
    return _service.getAllCategories();
  }

  @override
  Future<Result<int>> createCategory(CustomCategory category) {
    return _service.insertCategory(category);
  }

  @override
  Future<Result<int>> deleteCategory(int id) {
    return _service.deleteCategory(id);
  }
}

import 'package:rich_ludo/domain/model/custom_category.dart';
import 'package:rich_ludo/domain/repository/category_repository.dart';
import 'package:rich_ludo/utils/result.dart';

class FakeCategoryRepository implements CategoryRepository {
  final List<CustomCategory> _categories = [];
  bool shouldReturnError = false;

  void addCategory(CustomCategory category) {
    _categories.add(category);
  }

  void clear() {
    _categories.clear();
  }

  @override
  Future<Result<List<CustomCategory>>> getCategories() async {
    if (shouldReturnError) {
      return Result.error(Exception('Simulated error'));
    }
    return Result.ok(List.unmodifiable(_categories));
  }

  @override
  Future<Result<int>> createCategory(CustomCategory category) async {
    if (shouldReturnError) {
      return Result.error(Exception('Simulated error'));
    }
    final newId = _categories.length + 1;
    _categories.add(category.copyWith(id: newId));
    return Result.ok(newId);
  }

  @override
  Future<Result<int>> deleteCategory(int id) async {
    if (shouldReturnError) {
      return Result.error(Exception('Simulated error'));
    }
    final initialLength = _categories.length;
    _categories.removeWhere((category) => category.id == id);
    return Result.ok(initialLength - _categories.length);
  }
}

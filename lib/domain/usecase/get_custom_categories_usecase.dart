import '../model/custom_category.dart';
import '../repository/category_repository.dart';
import '../../utils/result.dart';

class GetCustomCategoriesUseCase {
  final CategoryRepository _repository;

  GetCustomCategoriesUseCase(this._repository);

  Future<Result<List<CustomCategory>>> call() => _repository.getCategories();
}

import '../model/custom_category.dart';
import '../repository/category_repository.dart';
import '../../utils/result.dart';

/// Why a user-created category was refused.
enum CategoryValidationError { emptyName, nameTooLong, duplicateName }

class CategoryValidationException implements Exception {
  final CategoryValidationError reason;

  const CategoryValidationException(this.reason);

  @override
  String toString() => 'CategoryValidationException(${reason.name})';
}

class CreateCustomCategoryUseCase {
  final CategoryRepository _repository;

  /// Longest category name the user may type.
  static const int maxNameLength = 30;

  CreateCustomCategoryUseCase(this._repository);

  Future<Result<int>> call(CustomCategory category) async {
    final name = category.name.trim();

    if (name.isEmpty || category.slug == CustomCategory.slugPrefix) {
      return const Result<int>.error(
        CategoryValidationException(CategoryValidationError.emptyName),
      );
    }

    if (name.length > maxNameLength) {
      return const Result<int>.error(
        CategoryValidationException(CategoryValidationError.nameTooLong),
      );
    }

    final existingResult = await _repository.getCategories();
    if (existingResult case Error<List<CustomCategory>>(:final error)) {
      return Result.error(error);
    }

    final isDuplicate = existingResult.asOk.value.any(
      (existing) =>
          existing.slug == category.slug && existing.type == category.type,
    );
    if (isDuplicate) {
      return const Result<int>.error(
        CategoryValidationException(CategoryValidationError.duplicateName),
      );
    }

    return _repository.createCategory(category);
  }
}

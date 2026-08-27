import 'package:flutter/foundation.dart';
import '../../domain/model/custom_category.dart';
import '../../domain/model/transaction_type.dart';
import '../../domain/usecase/create_custom_category_usecase.dart';
import '../../domain/usecase/delete_custom_category_usecase.dart';
import '../../domain/usecase/get_custom_categories_usecase.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

class CategoryViewModel extends ChangeNotifier {
  final GetCustomCategoriesUseCase _getCustomCategoriesUseCase;
  final CreateCustomCategoryUseCase _createCustomCategoryUseCase;
  final DeleteCustomCategoryUseCase _deleteCustomCategoryUseCase;

  List<CustomCategory> _categories = [];

  late final Command0<List<CustomCategory>> load;

  late final Command1<int, CustomCategory> create;

  late final Command1<int, CustomCategory> delete;

  CategoryViewModel({
    required GetCustomCategoriesUseCase getCustomCategoriesUseCase,
    required CreateCustomCategoryUseCase createCustomCategoryUseCase,
    required DeleteCustomCategoryUseCase deleteCustomCategoryUseCase,
  }) : _getCustomCategoriesUseCase = getCustomCategoriesUseCase,
       _createCustomCategoryUseCase = createCustomCategoryUseCase,
       _deleteCustomCategoryUseCase = deleteCustomCategoryUseCase {
    load = Command0<List<CustomCategory>>(_loadCategories);
    create = Command1<int, CustomCategory>(_createCategory);
    delete = Command1<int, CustomCategory>(_deleteCategory);

    load.execute();
  }

  List<CustomCategory> get categories => _categories;

  /// The user-created categories that belong to [type], in the order the
  /// service returned them.
  List<CustomCategory> categoriesFor(TransactionType type) {
    return _categories.where((category) => category.type == type).toList();
  }

  Future<Result<List<CustomCategory>>> _loadCategories() async {
    final result = await _getCustomCategoriesUseCase();

    switch (result) {
      case Ok<List<CustomCategory>>(:final value):
        _categories = value;
        notifyListeners();
      case Error<List<CustomCategory>>():
        debugPrint('Error loading categories: ${result.error}');
    }

    return result;
  }

  Future<Result<int>> _createCategory(CustomCategory category) async {
    final result = await _createCustomCategoryUseCase(category);

    switch (result) {
      case Ok<int>():
        await _loadCategories();
      case Error<int>():
        debugPrint('Error creating category: ${result.error}');
    }

    return result;
  }

  Future<Result<int>> _deleteCategory(CustomCategory category) async {
    final result = await _deleteCustomCategoryUseCase(category);

    switch (result) {
      case Ok<int>():
        await _loadCategories();
      case Error<int>():
        debugPrint('Error deleting category: ${result.error}');
    }

    return result;
  }
}

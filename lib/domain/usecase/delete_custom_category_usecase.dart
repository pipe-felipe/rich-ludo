import '../model/custom_category.dart';
import '../model/transaction.dart';
import '../repository/category_repository.dart';
import '../repository/transaction_repository.dart';
import '../../utils/result.dart';

/// Raised when a category still labels at least one transaction.
/// Deleting is refused in that case, so no stored transaction is ever
/// left pointing at a category the user cannot see.
class CategoryInUseException implements Exception {
  final int transactionCount;

  const CategoryInUseException(this.transactionCount);

  @override
  String toString() => 'CategoryInUseException($transactionCount)';
}

class DeleteCustomCategoryUseCase {
  final CategoryRepository _categoryRepository;
  final TransactionRepository _transactionRepository;

  DeleteCustomCategoryUseCase(
    this._categoryRepository,
    this._transactionRepository,
  );

  Future<Result<int>> call(CustomCategory category) async {
    final transactionsResult = await _transactionRepository.getTransactions();
    if (transactionsResult case Error<List<Transaction>>(:final error)) {
      return Result.error(error);
    }

    final usageCount = transactionsResult.asOk.value
        .where((tx) => tx.category == category.slug)
        .length;

    if (usageCount > 0) {
      return Result.error(CategoryInUseException(usageCount));
    }

    return _categoryRepository.deleteCategory(category.id);
  }
}

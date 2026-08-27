import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/custom_category.dart';
import 'package:rich_ludo/domain/model/transaction.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/domain/usecase/delete_custom_category_usecase.dart';

import '../../fakes/fake_category_repository.dart';
import '../../fakes/fake_transaction_repository.dart';

void main() {
  late FakeCategoryRepository categoryRepository;
  late FakeTransactionRepository transactionRepository;
  late DeleteCustomCategoryUseCase useCase;

  const category = CustomCategory(
    id: 1,
    slug: 'custom_mercado',
    name: 'Mercado',
    type: TransactionType.expense,
    iconCodePoint: 0xe59c,
    colorValue: 0xFFC62828,
  );

  setUp(() {
    categoryRepository = FakeCategoryRepository();
    transactionRepository = FakeTransactionRepository();
    categoryRepository.addCategory(category);
    useCase = DeleteCustomCategoryUseCase(
      categoryRepository,
      transactionRepository,
    );
  });

  group('DeleteCustomCategoryUseCase', () {
    test('should delete the category when no transaction uses it', () async {
      final result = await useCase(category);

      expect(result.isOk, isTrue);
      expect(result.asOk.value, equals(1));
      expect((await categoryRepository.getCategories()).asOk.value, isEmpty);
    });

    test('should delete when transactions use other categories only', () async {
      transactionRepository.addTransaction(_transaction('food'));
      transactionRepository.addTransaction(_transaction(null));

      final result = await useCase(category);

      expect(result.isOk, isTrue);
    });

    test(
      'should refuse and report the number of transactions in use',
      () async {
        transactionRepository.addTransaction(_transaction('custom_mercado'));
        transactionRepository.addTransaction(_transaction('custom_mercado'));
        transactionRepository.addTransaction(_transaction('food'));

        final result = await useCase(category);

        expect(result.isError, isTrue);
        expect(
          (result.asError.error as CategoryInUseException).transactionCount,
          equals(2),
        );
      },
    );

    test('should keep the category when the deletion is refused', () async {
      transactionRepository.addTransaction(_transaction('custom_mercado'));

      await useCase(category);

      expect(
        (await categoryRepository.getCategories()).asOk.value,
        hasLength(1),
      );
    });

    test('should propagate the transaction repository error', () async {
      transactionRepository.shouldReturnError = true;

      final result = await useCase(category);

      expect(result.isError, isTrue);
      expect(result.asError.error, isNot(isA<CategoryInUseException>()));
    });
  });
}

Transaction _transaction(String? category) {
  return Transaction(
    amountCents: 1000,
    type: TransactionType.expense,
    category: category,
    humanDate: '2026-08-02',
    targetMonth: 8,
    targetYear: 2026,
  );
}

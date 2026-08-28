import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/domain/model/custom_category.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/domain/usecase/create_custom_category_usecase.dart';

import '../../fakes/fake_category_repository.dart';

void main() {
  late FakeCategoryRepository repository;
  late CreateCustomCategoryUseCase useCase;

  setUp(() {
    repository = FakeCategoryRepository();
    useCase = CreateCustomCategoryUseCase(repository);
  });

  group('CreateCustomCategoryUseCase', () {
    test(
      'should create the category and return Result.ok with its id',
      () async {
        final result = await useCase(_draft('Mercado'));

        expect(result.isOk, isTrue);
        expect(result.asOk.value, equals(1));
        expect((await repository.getCategories()).asOk.value, hasLength(1));
      },
    );

    test(
      'should return emptyName when the name has no letter or digit',
      () async {
        final result = await useCase(_draft('   '));

        expect(result.isError, isTrue);
        expect(
          (result.asError.error as CategoryValidationException).reason,
          equals(CategoryValidationError.emptyName),
        );
      },
    );

    test(
      'should return nameTooLong when the name exceeds 30 characters',
      () async {
        final result = await useCase(_draft('A' * 31));

        expect(result.isError, isTrue);
        expect(
          (result.asError.error as CategoryValidationException).reason,
          equals(CategoryValidationError.nameTooLong),
        );
      },
    );

    test('should accept a name of exactly 30 characters', () async {
      final result = await useCase(_draft('A' * 30));

      expect(result.isOk, isTrue);
    });

    test('should return duplicateName for the same slug and type', () async {
      await useCase(_draft('Mercado'));

      final result = await useCase(_draft('  MERCADO  '));

      expect(result.isError, isTrue);
      expect(
        (result.asError.error as CategoryValidationException).reason,
        equals(CategoryValidationError.duplicateName),
      );
    });

    test(
      'should accept the same name for the other transaction type',
      () async {
        await useCase(_draft('Bonus'));

        final result = await useCase(
          CustomCategory.draft(
            name: 'Bonus',
            type: TransactionType.income,
            iconCodePoint: 0xe553,
            colorValue: 0xFF2E7D32,
          ),
        );

        expect(result.isOk, isTrue);
      },
    );

    test('should propagate the repository error', () async {
      repository.shouldReturnError = true;

      final result = await useCase(_draft('Mercado'));

      expect(result.isError, isTrue);
      expect(result.asError.error, isNot(isA<CategoryValidationException>()));
    });
  });
}

CustomCategory _draft(String name) {
  return CustomCategory.draft(
    name: name,
    type: TransactionType.expense,
    iconCodePoint: 0xe59c,
    colorValue: 0xFFC62828,
  );
}

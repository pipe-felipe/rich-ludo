import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rich_ludo/domain/model/custom_category.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/domain/usecase/create_custom_category_usecase.dart';
import 'package:rich_ludo/domain/usecase/delete_custom_category_usecase.dart';
import 'package:rich_ludo/domain/usecase/get_custom_categories_usecase.dart';
import 'package:rich_ludo/presentation/viewmodel/category_viewmodel.dart';
import 'package:rich_ludo/utils/result.dart';

class MockGetCustomCategoriesUseCase extends Mock
    implements GetCustomCategoriesUseCase {}

class MockCreateCustomCategoryUseCase extends Mock
    implements CreateCustomCategoryUseCase {}

class MockDeleteCustomCategoryUseCase extends Mock
    implements DeleteCustomCategoryUseCase {}

class FakeCustomCategory extends Fake implements CustomCategory {}

void main() {
  late MockGetCustomCategoriesUseCase mockGetCustomCategoriesUseCase;
  late MockCreateCustomCategoryUseCase mockCreateCustomCategoryUseCase;
  late MockDeleteCustomCategoryUseCase mockDeleteCustomCategoryUseCase;

  const expenseCategory = CustomCategory(
    id: 1,
    slug: 'custom_mercado',
    name: 'Mercado',
    type: TransactionType.expense,
    iconCodePoint: 0xe59c,
    colorValue: 0xFFC62828,
  );

  const incomeCategory = CustomCategory(
    id: 2,
    slug: 'custom_bonus',
    name: 'Bonus',
    type: TransactionType.income,
    iconCodePoint: 0xe553,
    colorValue: 0xFF2E7D32,
  );

  CategoryViewModel buildViewModel() {
    return CategoryViewModel(
      getCustomCategoriesUseCase: mockGetCustomCategoriesUseCase,
      createCustomCategoryUseCase: mockCreateCustomCategoryUseCase,
      deleteCustomCategoryUseCase: mockDeleteCustomCategoryUseCase,
    );
  }

  // The constructor starts `load`; poll until it settles, mirroring
  // `waitForLoad` in main_screen_viewmodel_test.dart.
  Future<void> waitForLoad(CategoryViewModel viewModel) async {
    while (viewModel.load.running) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  setUpAll(() {
    registerFallbackValue(FakeCustomCategory());
  });

  setUp(() {
    mockGetCustomCategoriesUseCase = MockGetCustomCategoriesUseCase();
    mockCreateCustomCategoryUseCase = MockCreateCustomCategoryUseCase();
    mockDeleteCustomCategoryUseCase = MockDeleteCustomCategoryUseCase();

    when(() => mockGetCustomCategoriesUseCase()).thenAnswer(
      (_) async => const Result.ok([expenseCategory, incomeCategory]),
    );
  });

  group('CategoryViewModel', () {
    test('should load the categories on construction', () async {
      final viewModel = buildViewModel();
      await waitForLoad(viewModel);

      expect(viewModel.categories, equals([expenseCategory, incomeCategory]));
      verify(() => mockGetCustomCategoriesUseCase()).called(1);

      viewModel.dispose();
    });

    test('should keep an empty list when loading fails', () async {
      when(
        () => mockGetCustomCategoriesUseCase(),
      ).thenAnswer((_) async => Result.error(Exception('Database error')));

      final viewModel = buildViewModel();
      await waitForLoad(viewModel);

      expect(viewModel.categories, isEmpty);
      expect(viewModel.load.error, isTrue);

      viewModel.dispose();
    });

    test('categoriesFor should return only the expense categories', () async {
      final viewModel = buildViewModel();
      await waitForLoad(viewModel);

      expect(
        viewModel.categoriesFor(TransactionType.expense),
        equals([expenseCategory]),
      );

      viewModel.dispose();
    });

    test('categoriesFor should return only the income categories', () async {
      final viewModel = buildViewModel();
      await waitForLoad(viewModel);

      expect(
        viewModel.categoriesFor(TransactionType.income),
        equals([incomeCategory]),
      );

      viewModel.dispose();
    });

    test('create should reload the categories when it succeeds', () async {
      when(
        () => mockCreateCustomCategoryUseCase(any()),
      ).thenAnswer((_) async => const Result.ok(3));

      final viewModel = buildViewModel();
      await waitForLoad(viewModel);
      clearInteractions(mockGetCustomCategoriesUseCase);

      await viewModel.create.execute(expenseCategory);

      expect(viewModel.create.completed, isTrue);
      verify(() => mockGetCustomCategoriesUseCase()).called(1);

      viewModel.dispose();
    });

    test('create should not reload when it fails', () async {
      when(() => mockCreateCustomCategoryUseCase(any())).thenAnswer(
        (_) async => const Result<int>.error(
          CategoryValidationException(CategoryValidationError.duplicateName),
        ),
      );

      final viewModel = buildViewModel();
      await waitForLoad(viewModel);
      clearInteractions(mockGetCustomCategoriesUseCase);

      await viewModel.create.execute(expenseCategory);

      expect(viewModel.create.error, isTrue);
      verifyNever(() => mockGetCustomCategoriesUseCase());

      viewModel.dispose();
    });

    test('delete should reload the categories when it succeeds', () async {
      when(
        () => mockDeleteCustomCategoryUseCase(any()),
      ).thenAnswer((_) async => const Result.ok(1));

      final viewModel = buildViewModel();
      await waitForLoad(viewModel);
      clearInteractions(mockGetCustomCategoriesUseCase);

      await viewModel.delete.execute(expenseCategory);

      expect(viewModel.delete.completed, isTrue);
      verify(() => mockGetCustomCategoriesUseCase()).called(1);

      viewModel.dispose();
    });

    test('delete should expose the in-use error without reloading', () async {
      when(() => mockDeleteCustomCategoryUseCase(any())).thenAnswer(
        (_) async => const Result<int>.error(CategoryInUseException(4)),
      );

      final viewModel = buildViewModel();
      await waitForLoad(viewModel);
      clearInteractions(mockGetCustomCategoriesUseCase);

      await viewModel.delete.execute(expenseCategory);

      final result = viewModel.delete.result;
      expect(result, isNotNull);
      expect(
        (result!.asError.error as CategoryInUseException).transactionCount,
        equals(4),
      );
      verifyNever(() => mockGetCustomCategoriesUseCase());

      viewModel.dispose();
    });
  });
}

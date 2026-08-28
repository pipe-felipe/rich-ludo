import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rich_ludo/data/repository/category_repository_impl.dart';
import 'package:rich_ludo/data/services/category_service.dart';
import 'package:rich_ludo/domain/model/custom_category.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
import 'package:rich_ludo/utils/result.dart';

class MockCategoryService extends Mock implements CategoryService {}

class FakeCustomCategory extends Fake implements CustomCategory {}

void main() {
  late MockCategoryService mockService;
  late CategoryRepositoryImpl repository;

  const category = CustomCategory(
    id: 1,
    slug: 'custom_mercado',
    name: 'Mercado',
    type: TransactionType.expense,
    iconCodePoint: 0xe59c,
    colorValue: 0xFFC62828,
  );

  setUpAll(() {
    registerFallbackValue(FakeCustomCategory());
  });

  setUp(() {
    mockService = MockCategoryService();
    repository = CategoryRepositoryImpl(service: mockService);
  });

  group('CategoryRepositoryImpl', () {
    group('getCategories', () {
      test('should return Result.ok with categories from Service', () async {
        when(
          () => mockService.getAllCategories(),
        ).thenAnswer((_) async => const Result.ok([category]));

        final result = await repository.getCategories();

        expect(result.isOk, isTrue);
        expect(result.asOk.value, equals([category]));
        verify(() => mockService.getAllCategories()).called(1);
      });

      test('should propagate the Service error', () async {
        when(
          () => mockService.getAllCategories(),
        ).thenAnswer((_) async => Result.error(Exception('Database error')));

        final result = await repository.getCategories();

        expect(result.isError, isTrue);
      });
    });

    group('createCategory', () {
      test('should return Result.ok with the new id from Service', () async {
        when(
          () => mockService.insertCategory(any()),
        ).thenAnswer((_) async => const Result.ok(9));

        final result = await repository.createCategory(category);

        expect(result.isOk, isTrue);
        expect(result.asOk.value, equals(9));
        verify(() => mockService.insertCategory(category)).called(1);
      });

      test('should propagate the Service error', () async {
        when(
          () => mockService.insertCategory(any()),
        ).thenAnswer((_) async => Result.error(Exception('Database error')));

        final result = await repository.createCategory(category);

        expect(result.isError, isTrue);
      });
    });

    group('deleteCategory', () {
      test(
        'should return Result.ok with the deleted count from Service',
        () async {
          when(
            () => mockService.deleteCategory(any()),
          ).thenAnswer((_) async => const Result.ok(1));

          final result = await repository.deleteCategory(1);

          expect(result.isOk, isTrue);
          expect(result.asOk.value, equals(1));
          verify(() => mockService.deleteCategory(1)).called(1);
        },
      );

      test('should propagate the Service error', () async {
        when(
          () => mockService.deleteCategory(any()),
        ).thenAnswer((_) async => Result.error(Exception('Database error')));

        final result = await repository.deleteCategory(1);

        expect(result.isError, isTrue);
      });
    });
  });
}

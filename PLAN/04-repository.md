## BLOCK 4 — Add `CategoryRepository` and `CategoryRepositoryImpl`

**Depends on:** BLOCK 3 committed
**Touches:** `lib/domain/repository/category_repository.dart` (NEW), `lib/data/repository/category_repository_impl.dart` (NEW), `test/data/repository/category_repository_impl_test.dart` (NEW)

### Goal
`CategoryRepositoryImpl` forwards each of its three methods to the matching `CategoryService`
method and returns that service's `Result` unchanged.

### Context to read first
1. `lib/domain/repository/transaction_repository.dart` — the whole file (32 lines); the abstract-repository shape to mirror.
2. `lib/data/repository/transaction_repository_impl.dart` — the whole file (75 lines); the implementation shape to mirror: a `final` service field, a `{required TransactionService service}` constructor, and one-line `=>`-free `return _service.x();` bodies with `@override` on every method.
3. `test/data/repository/transaction_repository_impl_test.dart:1-40` — the repository-test style to mirror: `class MockTransactionService extends Mock implements TransactionService {}`, `registerFallbackValue` in `setUpAll`, a fresh mock in `setUp`, and one nested `group` per method.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Create `lib/domain/repository/category_repository.dart` with exactly this content:
   ```dart
   import '../model/custom_category.dart';
   import '../../utils/result.dart';

   abstract class CategoryRepository {
     Future<Result<List<CustomCategory>>> getCategories();

     Future<Result<int>> createCategory(CustomCategory category);

     Future<Result<int>> deleteCategory(int id);
   }
   ```
2. Create `lib/data/repository/category_repository_impl.dart` with exactly this content:
   ```dart
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
   ```
3. Create `test/data/repository/category_repository_impl_test.dart` with exactly these 6 tests:
   ```dart
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
         test('should return Result.ok with the deleted count from Service', () async {
           when(
             () => mockService.deleteCategory(any()),
           ).thenAnswer((_) async => const Result.ok(1));

           final result = await repository.deleteCategory(1);

           expect(result.isOk, isTrue);
           expect(result.asOk.value, equals(1));
           verify(() => mockService.deleteCategory(1)).called(1);
         });

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
   ```
4. Run the §5 `write-only` formatter on the Touches paths only:
   ```
   dart format lib/domain/repository/category_repository.dart lib/data/repository/category_repository_impl.dart test/data/repository/category_repository_impl_test.dart
   ```

### Do not
- Do not add validation, sorting, filtering or caching to `CategoryRepositoryImpl`. It delegates and nothing more, exactly like `TransactionRepositoryImpl`.
- Do not add a method that `CategoryService` does not declare.
- Do not modify `lib/domain/repository/transaction_repository.dart` or `lib/data/repository/transaction_repository_impl.dart` (§9).
- Do not create the use cases here — that is BLOCK 5.

### Verify
Run from the repository root, in this order:
```
flutter test test/data/repository/category_repository_impl_test.dart
flutter analyze
flutter test
```
Expected: the first command exits 0 and reports `+6`; `flutter analyze` exits 0 printing `No issues found!`; `flutter test` exits 0 and reports `All tests passed!` with 252 tests (246 after BLOCK 3, plus 6).

### If verification fails
1. Read the failing output in full.
2. Fix only `lib/domain/repository/category_repository.dart`, `lib/data/repository/category_repository_impl.dart` and `test/data/repository/category_repository_impl_test.dart`.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 4's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/domain/repository/category_repository.dart lib/data/repository/category_repository_impl.dart test/data/repository/category_repository_impl_test.dart PLAN.md
   git commit -m "Add the category repository over the category service"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

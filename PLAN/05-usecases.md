## BLOCK 5 — Add the three category use cases

**Depends on:** BLOCK 4 committed
**Touches:** `lib/domain/usecase/get_custom_categories_usecase.dart` (NEW), `lib/domain/usecase/create_custom_category_usecase.dart` (NEW), `lib/domain/usecase/delete_custom_category_usecase.dart` (NEW), `test/fakes/fake_category_repository.dart` (NEW), `test/domain/usecase/create_custom_category_usecase_test.dart` (NEW), `test/domain/usecase/delete_custom_category_usecase_test.dart` (NEW)

6 files: three one-purpose use-case files plus the one fake both use-case tests need and their
two mirrored test files. Every path is listed. `GetCustomCategoriesUseCase` gets no test file of
its own — §10 records why.

### Goal
`CreateCustomCategoryUseCase` rejects an empty name, a name longer than 30 characters and a
duplicate, and `DeleteCustomCategoryUseCase` refuses to delete while any transaction carries the
category, reporting the exact count.

### Context to read first
1. `lib/domain/usecase/make_transaction_usecase.dart` — the whole file (67 lines); the use-case shape to mirror: a single positional repository in the constructor, one public `call(...)`, private helpers below it, and reading `_repository.getTransactions()` to inspect existing rows.
2. `lib/domain/usecase/delete_recurring_transaction_usecase.dart:1-20` — the precedent for declaring a type that belongs to a use case (`RecurringDeleteMode`) in the use case's own file.
3. `lib/utils/result.dart` — the whole file (55 lines); `Ok<T>` / `Error<T>`, `isOk`, `isError`, `asOk`, `asError`, and the `const factory Result.error(Exception error)` these files use.
4. `test/fakes/fake_transaction_repository.dart` — the whole file (163 lines); the fake shape to mirror: an in-memory list, a `shouldReturnError` flag checked at the top of every method, an `addTransaction` seeding helper, and a `clear()`.
5. `test/domain/usecase/make_transaction_usecase_test.dart:1-30` — the use-case test style to mirror: the fake built in `setUp`, one `group` named after the use case, English `should ...` test names.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Create `lib/domain/usecase/get_custom_categories_usecase.dart` with exactly this content:
   ```dart
   import '../model/custom_category.dart';
   import '../repository/category_repository.dart';
   import '../../utils/result.dart';

   class GetCustomCategoriesUseCase {
     final CategoryRepository _repository;

     GetCustomCategoriesUseCase(this._repository);

     Future<Result<List<CustomCategory>>> call() => _repository.getCategories();
   }
   ```
2. Create `lib/domain/usecase/create_custom_category_usecase.dart` with exactly this content:
   ```dart
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
   ```
3. Create `lib/domain/usecase/delete_custom_category_usecase.dart` with exactly this content:
   ```dart
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
   ```
4. Create `test/fakes/fake_category_repository.dart` with exactly this content:
   ```dart
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
   ```
5. Create `test/domain/usecase/create_custom_category_usecase_test.dart` with exactly these 7 tests:
   ```dart
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
       test('should create the category and return Result.ok with its id', () async {
         final result = await useCase(_draft('Mercado'));

         expect(result.isOk, isTrue);
         expect(result.asOk.value, equals(1));
         expect((await repository.getCategories()).asOk.value, hasLength(1));
       });

       test('should return emptyName when the name has no letter or digit', () async {
         final result = await useCase(_draft('   '));

         expect(result.isError, isTrue);
         expect(
           (result.asError.error as CategoryValidationException).reason,
           equals(CategoryValidationError.emptyName),
         );
       });

       test('should return nameTooLong when the name exceeds 30 characters', () async {
         final result = await useCase(_draft('A' * 31));

         expect(result.isError, isTrue);
         expect(
           (result.asError.error as CategoryValidationException).reason,
           equals(CategoryValidationError.nameTooLong),
         );
       });

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

       test('should accept the same name for the other transaction type', () async {
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
       });

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
   ```
6. Create `test/domain/usecase/delete_custom_category_usecase_test.dart` with exactly these 5 tests:
   ```dart
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

       test('should refuse and report the number of transactions in use', () async {
         transactionRepository.addTransaction(_transaction('custom_mercado'));
         transactionRepository.addTransaction(_transaction('custom_mercado'));
         transactionRepository.addTransaction(_transaction('food'));

         final result = await useCase(category);

         expect(result.isError, isTrue);
         expect(
           (result.asError.error as CategoryInUseException).transactionCount,
           equals(2),
         );
       });

       test('should keep the category when the deletion is refused', () async {
         transactionRepository.addTransaction(_transaction('custom_mercado'));

         await useCase(category);

         expect((await categoryRepository.getCategories()).asOk.value, hasLength(1));
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
   ```
7. Run the §5 `write-only` formatter on the Touches paths only:
   ```
   dart format lib/domain/usecase/get_custom_categories_usecase.dart lib/domain/usecase/create_custom_category_usecase.dart lib/domain/usecase/delete_custom_category_usecase.dart test/fakes/fake_category_repository.dart test/domain/usecase/create_custom_category_usecase_test.dart test/domain/usecase/delete_custom_category_usecase_test.dart
   ```

### Do not
- Do not add a method to `test/fakes/fake_transaction_repository.dart` or to `lib/domain/repository/transaction_repository.dart` to count transactions (§9). `getTransactions()` already returns everything the count needs.
- Do not add an `UpdateCustomCategoryUseCase`. §3 puts renaming out of scope.
- Do not add a shared base class or a shared exception hierarchy for `CategoryValidationException` and `CategoryInUseException`. Each is used by exactly one use case.
- Do not compare category names case-insensitively anywhere but through the slug: `CustomCategory.slugFor` already lowercases, which is what makes `'  MERCADO  '` a duplicate of `'Mercado'` in the test at step 5.
- Do not create `CategoryViewModel` or edit `lib/main.dart` — that is BLOCK 6.

### Verify
Run from the repository root, in this order:
```
flutter test test/domain/usecase/create_custom_category_usecase_test.dart test/domain/usecase/delete_custom_category_usecase_test.dart
flutter analyze
flutter test
```
Expected: the first command exits 0 and reports `+12` (7 plus 5); `flutter analyze` exits 0 printing `No issues found!`; `flutter test` exits 0 and reports `All tests passed!` with 264 tests (252 after BLOCK 4, plus 12).

### If verification fails
1. Read the failing output in full.
2. Fix only the six files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 5's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/domain/usecase/get_custom_categories_usecase.dart lib/domain/usecase/create_custom_category_usecase.dart lib/domain/usecase/delete_custom_category_usecase.dart test/fakes/fake_category_repository.dart test/domain/usecase/create_custom_category_usecase_test.dart test/domain/usecase/delete_custom_category_usecase_test.dart PLAN.md
   git commit -m "Add the create, delete and list category use cases"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

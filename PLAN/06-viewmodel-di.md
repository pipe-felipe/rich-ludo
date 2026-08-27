## BLOCK 6 — Add `CategoryViewModel` and wire it in `main.dart`

**Depends on:** BLOCK 5 committed
**Touches:** `lib/presentation/viewmodel/category_viewmodel.dart` (NEW), `test/presentation/viewmodel/category_viewmodel_test.dart` (NEW), `lib/main.dart` (MODIFY)

### Goal
`CategoryViewModel` exposes the user-created categories, reloads them after a successful create
and after a successful delete, and is reachable from any widget through `Provider`.

### Context to read first
1. `lib/presentation/viewmodel/main_screen_viewmodel.dart:17-107` — the ViewModel shape to mirror: `extends ChangeNotifier`, `final` use-case fields, `late final CommandN` fields declared before the constructor, commands built in the constructor body, `load.execute()` at the end of the constructor, plain getters, and `switch (result) { case Ok<T>(:final value): ... case Error<T>(): debugPrint(...) }`.
2. `lib/utils/command.dart` — the whole file (69 lines); `Command0<T>` takes `Future<Result<T>> Function()`, `Command1<T, A>` takes `Future<Result<T>> Function(A)` and its `execute(A arg)`.
3. `lib/main.dart:38-100` — the provider block to extend: services first, then repositories, then use cases, then `ChangeNotifierProvider` ViewModels, each built with `context.read<...>()`.
4. `test/presentation/viewmodel/main_screen_viewmodel_test.dart:1-60` — the ViewModel test style to mirror: one `class MockXUseCase extends Mock implements XUseCase {}` per use case, `registerFallbackValue` in `setUpAll`, `when(...)` stubs set before the ViewModel is built because its constructor calls `load.execute()`, and `viewModel.dispose()` at the end of every test.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Create `lib/presentation/viewmodel/category_viewmodel.dart` with exactly this content:
   ```dart
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
   ```
2. Create `test/presentation/viewmodel/category_viewmodel_test.dart` with exactly these 8 tests:
   ```dart
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

       when(
         () => mockGetCustomCategoriesUseCase(),
       ).thenAnswer((_) async => const Result.ok([expenseCategory, incomeCategory]));
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
         when(
           () => mockDeleteCustomCategoryUseCase(any()),
         ).thenAnswer((_) async => const Result<int>.error(CategoryInUseException(4)));

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
   ```
3. In `lib/main.dart`, add these imports. Put the two data imports next to the existing `data/services/...` and `data/repository/...` lines, the domain import next to `domain/repository/transaction_repository.dart`, the three use-case imports next to the existing `domain/usecase/...` block, and the ViewModel import next to `presentation/viewmodel/transaction_form_viewmodel.dart`:
   ```dart
   import 'data/services/category_service.dart';
   import 'data/services/category_local_service.dart';
   import 'data/repository/category_repository_impl.dart';
   import 'domain/repository/category_repository.dart';
   import 'domain/usecase/create_custom_category_usecase.dart';
   import 'domain/usecase/delete_custom_category_usecase.dart';
   import 'domain/usecase/get_custom_categories_usecase.dart';
   import 'presentation/viewmodel/category_viewmodel.dart';
   ```
4. In `lib/main.dart`, immediately after the line `Provider<ExportService>(create: (_) => ExportLocalService()),`, insert:
   ```dart
   Provider<CategoryService>(create: (_) => CategoryLocalService()),
   ```
5. In `lib/main.dart`, immediately after the closing `),` of the existing `Provider<TransactionRepository>(...)` entry, insert:
   ```dart
   Provider<CategoryRepository>(
     create: (context) =>
         CategoryRepositoryImpl(service: context.read<CategoryService>()),
   ),
   ```
6. In `lib/main.dart`, immediately after the closing `),` of the existing `Provider<ImportDatabaseUseCase>(...)` entry, insert:
   ```dart
   Provider<GetCustomCategoriesUseCase>(
     create: (context) =>
         GetCustomCategoriesUseCase(context.read<CategoryRepository>()),
   ),
   Provider<CreateCustomCategoryUseCase>(
     create: (context) =>
         CreateCustomCategoryUseCase(context.read<CategoryRepository>()),
   ),
   Provider<DeleteCustomCategoryUseCase>(
     create: (context) => DeleteCustomCategoryUseCase(
       context.read<CategoryRepository>(),
       context.read<TransactionRepository>(),
     ),
   ),
   ```
7. In `lib/main.dart`, immediately after the closing `),` of the existing `ChangeNotifierProvider<TransactionFormViewModel>(...)` entry and before the closing `]` of the `providers:` list, insert:
   ```dart
   ChangeNotifierProvider<CategoryViewModel>(
     create: (context) => CategoryViewModel(
       getCustomCategoriesUseCase: context.read<GetCustomCategoriesUseCase>(),
       createCustomCategoryUseCase: context.read<CreateCustomCategoryUseCase>(),
       deleteCustomCategoryUseCase: context.read<DeleteCustomCategoryUseCase>(),
     ),
   ),
   ```
8. Run the §5 `write-only` formatter on the Touches paths only. `lib/main.dart` is one of the 7 files §6 records as already unformatted, so this step reformats parts of it that this block did not edit — that is expected and belongs in this block's commit:
   ```
   dart format lib/presentation/viewmodel/category_viewmodel.dart test/presentation/viewmodel/category_viewmodel_test.dart lib/main.dart
   ```

### Do not
- Do not add a `lazy: false` argument, an `invalidateAndReload`, a month cache, or a `_needsReload` queue to `CategoryViewModel`. Categories change only when the user creates or deletes one, and both paths already reload.
- Do not add a `dispose()` override to `CategoryViewModel`: unlike `MainScreenViewModel`, it registers no command listener, so there is nothing to remove.
- Do not change any existing provider entry in `lib/main.dart`, and do not reorder the existing ones.
- Do not make any widget read `CategoryViewModel` yet — that is BLOCK 10, BLOCK 11 and BLOCK 12.
- Do not add localization keys here — that is BLOCK 7.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/viewmodel/category_viewmodel_test.dart
flutter analyze
flutter test
```
Expected: the first command exits 0 and reports `+8`; `flutter analyze` exits 0 printing `No issues found!`; `flutter test` exits 0 and reports `All tests passed!` with 272 tests (264 after BLOCK 5, plus 8).

### If verification fails
1. Read the failing output in full.
2. Fix only `lib/presentation/viewmodel/category_viewmodel.dart`, `test/presentation/viewmodel/category_viewmodel_test.dart` and `lib/main.dart`.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 6's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/viewmodel/category_viewmodel.dart test/presentation/viewmodel/category_viewmodel_test.dart lib/main.dart PLAN.md
   git commit -m "Add CategoryViewModel and provide it from main"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

## BLOCK 11 — Offer user-created categories in the transaction dropdown

**Depends on:** BLOCK 10 committed
**Touches:** `lib/presentation/ui/widgets/transaction_dialog.dart` (MODIFY), `test/presentation/ui/widgets/transaction_dialog_test.dart` (NEW)

### Goal
The category dropdown of the transaction dialog lists the 13 built-in options, then the user's
categories of the current transaction type, then a `Nova categoria` entry that opens
`CategoryManagerDialog` and selects whatever the user just created.

### Context to read first
1. `lib/presentation/ui/widgets/transaction_dialog.dart` — the whole file as BLOCK 9 left it; `TransactionDialog.build` and its `Consumer<TransactionFormViewModel>`, `_CategoryAndQuantityInput`, `_CategoryOption`, `_builtInOptions`, and `_CategoryDropdown`.
2. `lib/presentation/ui/widgets/category_manager_dialog.dart` — `CategoryManagerDialog.show(context, type)` returns `Future<String?>`: the slug just created, or `null`.
3. `lib/presentation/viewmodel/category_viewmodel.dart` — `categoriesFor(TransactionType)`.
4. `test/presentation/ui/widgets/category_manager_dialog_test.dart` — the widget-test harness to mirror: the provider above `MaterialApp`, the enlarged `tester.view.physicalSize`, and the mocktail mocks of the use cases.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `lib/presentation/ui/widgets/transaction_dialog.dart`, add these three imports next to the existing ones, keeping the file's order of `domain`, then `l10n`, then `presentation`:
   ```dart
   import '../../../domain/model/custom_category.dart';
   import '../../viewmodel/category_viewmodel.dart';
   import 'category_manager_dialog.dart';
   ```
2. In the same file, immediately after the last `import` line and before `class TransactionDialog`, insert:
   ```dart

   /// Value of the dropdown entry that opens [CategoryManagerDialog]. It is never
   /// stored: `_CategoryDropdown` turns it into a dialog instead of a selection.
   const String _newCategoryOptionValue = '__new_category__';
   ```
3. In `TransactionDialog.build`, immediately after the line `final uiState = viewModel.uiState;`, insert:
   ```dart
   final customCategories = context
       .watch<CategoryViewModel>()
       .categoriesFor(uiState.transactionType);
   ```
4. In the same method, in the `_CategoryAndQuantityInput(...)` call, immediately after the line `uiState: uiState,`, insert:
   ```dart
   customCategories: customCategories,
   ```
5. In `_CategoryAndQuantityInput`, add the field and the constructor parameter. Replace
   ```dart
     final FormUiState uiState;
     final void Function(String) onCategoryChange;
     final void Function(String) onQuantityChange;

     const _CategoryAndQuantityInput({
       required this.uiState,
       required this.onCategoryChange,
       required this.onQuantityChange,
     });
   ```
   with:
   ```dart
     final FormUiState uiState;
     final List<CustomCategory> customCategories;
     final void Function(String) onCategoryChange;
     final void Function(String) onQuantityChange;

     const _CategoryAndQuantityInput({
       required this.uiState,
       required this.customCategories,
       required this.onCategoryChange,
       required this.onQuantityChange,
     });
   ```
6. In `_CategoryAndQuantityInput.build`, in the `_CategoryDropdown(...)` call, immediately after the line `transactionType: uiState.transactionType,`, insert:
   ```dart
   customCategories: customCategories,
   ```
7. In the same file, immediately after the closing brace of the `_builtInOptions` function, insert:
   ```dart

   List<_CategoryOption> _customOptions(List<CustomCategory> categories) {
     return categories
         .map(
           (category) => _CategoryOption(
             slug: category.slug,
             label: category.name,
             icon: resolveCustomCategoryIcon(category.iconCodePoint),
           ),
         )
         .toList();
   }
   ```
8. In the same file, replace the whole of `class _CategoryDropdown` — from its `class` line to its closing brace — with this stateful version:
   ```dart
   class _CategoryDropdown extends StatefulWidget {
     final TransactionType transactionType;
     final List<CustomCategory> customCategories;
     final String? categorySlug;
     final void Function(String) onCategoryChange;

     const _CategoryDropdown({
       required this.transactionType,
       required this.customCategories,
       required this.categorySlug,
       required this.onCategoryChange,
     });

     @override
     State<_CategoryDropdown> createState() => _CategoryDropdownState();
   }

   class _CategoryDropdownState extends State<_CategoryDropdown> {
     // Picking the "new category" entry leaves that entry showing inside the
     // form field, because DropdownButtonFormField keeps its own selection.
     // Bumping this token changes the field's key, which rebuilds it from
     // `initialValue` and drops the entry that was never a real choice.
     int _resetToken = 0;

     @override
     Widget build(BuildContext context) {
       final l10n = AppLocalizations.of(context)!;
       final options = [
         ..._builtInOptions(widget.transactionType, l10n),
         ..._customOptions(widget.customCategories),
         _CategoryOption(
           slug: _newCategoryOptionValue,
           label: l10n.categoryCreateNew,
           icon: Icons.add,
         ),
       ];
       // A slug that is not among the options would trip the dropdown's own
       // assertion, so an unknown or deleted one shows as nothing chosen.
       final selected =
           widget.categorySlug != _newCategoryOptionValue &&
               options.any((option) => option.slug == widget.categorySlug)
           ? widget.categorySlug
           : null;

       return DropdownButtonFormField<String>(
         key: ValueKey('$selected-$_resetToken'),
         initialValue: selected,
         isExpanded: true,
         decoration: InputDecoration(
           labelText: l10n.formCategoryLabel,
           border: const OutlineInputBorder(),
         ),
         selectedItemBuilder: (context) {
           return options.map((option) {
             return Row(
               children: [
                 Icon(option.icon, size: 18),
                 const SizedBox(width: 6),
                 Expanded(
                   child: Text(option.label, overflow: TextOverflow.ellipsis),
                 ),
               ],
             );
           }).toList();
         },
         items: options.map((option) {
           return DropdownMenuItem(
             value: option.slug,
             child: Row(
               children: [
                 Icon(option.icon, size: 18),
                 const SizedBox(width: 6),
                 Text(option.label),
               ],
             ),
           );
         }).toList(),
         onChanged: (value) async {
           if (value == null) return;

           if (value != _newCategoryOptionValue) {
             widget.onCategoryChange(value);
             return;
           }

           final createdSlug = await CategoryManagerDialog.show(
             context,
             widget.transactionType,
           );

           if (createdSlug != null) {
             widget.onCategoryChange(createdSlug);
           }
           if (mounted) {
             setState(() => _resetToken++);
           }
         },
       );
     }
   }
   ```
9. Create `test/presentation/ui/widgets/transaction_dialog_test.dart` with exactly these 3 tests:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:mocktail/mocktail.dart';
   import 'package:provider/provider.dart';
   import 'package:rich_ludo/domain/model/custom_category.dart';
   import 'package:rich_ludo/domain/model/transaction.dart';
   import 'package:rich_ludo/domain/model/transaction_type.dart';
   import 'package:rich_ludo/domain/usecase/create_custom_category_usecase.dart';
   import 'package:rich_ludo/domain/usecase/delete_custom_category_usecase.dart';
   import 'package:rich_ludo/domain/usecase/get_custom_categories_usecase.dart';
   import 'package:rich_ludo/domain/usecase/make_transaction_usecase.dart';
   import 'package:rich_ludo/l10n/app_localizations.dart';
   import 'package:rich_ludo/presentation/ui/theme/app_theme.dart';
   import 'package:rich_ludo/presentation/ui/widgets/category_manager_dialog.dart';
   import 'package:rich_ludo/presentation/ui/widgets/transaction_dialog.dart';
   import 'package:rich_ludo/presentation/viewmodel/category_viewmodel.dart';
   import 'package:rich_ludo/presentation/viewmodel/transaction_form_viewmodel.dart';
   import 'package:rich_ludo/utils/result.dart';

   class MockGetCustomCategoriesUseCase extends Mock
       implements GetCustomCategoriesUseCase {}

   class MockCreateCustomCategoryUseCase extends Mock
       implements CreateCustomCategoryUseCase {}

   class MockDeleteCustomCategoryUseCase extends Mock
       implements DeleteCustomCategoryUseCase {}

   class MockMakeTransactionUseCase extends Mock
       implements MakeTransactionUseCase {}

   class FakeCustomCategory extends Fake implements CustomCategory {}

   class FakeTransaction extends Fake implements Transaction {}

   void main() {
     late CategoryViewModel categoryViewModel;
     late TransactionFormViewModel formViewModel;

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

     setUpAll(() {
       registerFallbackValue(FakeCustomCategory());
       registerFallbackValue(FakeTransaction());
     });

     tearDown(() {
       categoryViewModel.dispose();
       formViewModel.dispose();
     });

     Future<void> openTransactionDialog(
       WidgetTester tester,
       List<CustomCategory> stored,
     ) async {
       final mockGet = MockGetCustomCategoriesUseCase();
       when(() => mockGet()).thenAnswer((_) async => Result.ok(stored));

       categoryViewModel = CategoryViewModel(
         getCustomCategoriesUseCase: mockGet,
         createCustomCategoryUseCase: MockCreateCustomCategoryUseCase(),
         deleteCustomCategoryUseCase: MockDeleteCustomCategoryUseCase(),
       );
       formViewModel = TransactionFormViewModel(
         makeTransactionUseCase: MockMakeTransactionUseCase(),
       );

       tester.view.physicalSize = const Size(1200, 2400);
       tester.view.devicePixelRatio = 1.0;
       addTearDown(tester.view.resetPhysicalSize);
       addTearDown(tester.view.resetDevicePixelRatio);

       await tester.pumpWidget(
         MultiProvider(
           providers: [
             ChangeNotifierProvider<CategoryViewModel>.value(
               value: categoryViewModel,
             ),
             ChangeNotifierProvider<TransactionFormViewModel>.value(
               value: formViewModel,
             ),
           ],
           child: MaterialApp(
             theme: AppTheme.lightTheme(),
             localizationsDelegates: AppLocalizations.localizationsDelegates,
             supportedLocales: AppLocalizations.supportedLocales,
             locale: const Locale('pt'),
             home: const Scaffold(
               body: TransactionDialog(selectedMonth: 8, selectedYear: 2026),
             ),
           ),
         ),
       );

       await tester.pumpAndSettle();
       await tester.tap(find.byType(DropdownButtonFormField<String>));
       await tester.pumpAndSettle();
     }

     group('TransactionDialog category dropdown', () {
       testWidgets('should list a user-created expense category', (tester) async {
         await openTransactionDialog(tester, const [expenseCategory]);

         expect(
           find.widgetWithText(DropdownMenuItem<String>, 'Mercado'),
           findsOneWidget,
         );
         expect(
           find.widgetWithText(DropdownMenuItem<String>, 'Comida'),
           findsOneWidget,
         );
       });

       testWidgets('should not list a user-created income category', (
         tester,
       ) async {
         await openTransactionDialog(tester, const [
           expenseCategory,
           incomeCategory,
         ]);

         expect(
           find.widgetWithText(DropdownMenuItem<String>, 'Bonus'),
           findsNothing,
         );
       });

       testWidgets('should open the category manager from the last entry', (
         tester,
       ) async {
         await openTransactionDialog(tester, const []);

         await tester.tap(
           find.widgetWithText(DropdownMenuItem<String>, 'Nova categoria'),
         );
         await tester.pumpAndSettle();

         expect(find.byType(CategoryManagerDialog), findsOneWidget);
       });
     });
   }
   ```
10. Run the §5 `write-only` formatter on the Touches paths only:
    ```
    dart format lib/presentation/ui/widgets/transaction_dialog.dart test/presentation/ui/widgets/transaction_dialog_test.dart
    ```

### Do not
- Do not call `onCategoryChange(_newCategoryOptionValue)`. The sentinel must never reach `FormUiState.categorySlug` or `transactions.category`.
- Do not put the `Nova categoria` entry anywhere but last in `options`, and do not add a second entry for deleting: deleting lives inside `CategoryManagerDialog` (BLOCK 10).
- Do not move `context` usage after the `await` in `onChanged` — `CategoryManagerDialog.show(context, ...)` reads it before awaiting, which is what keeps `use_build_context_synchronously` satisfied.
- Do not drop the `key: ValueKey('$selected-$_resetToken')`. Without it the field keeps showing `Nova categoria` after the manager dialog closes.
- Do not read `CategoryViewModel` inside `_CategoryDropdown`; it receives `customCategories` as a parameter from `TransactionDialog.build`.
- Do not touch `lib/presentation/ui/widgets/transaction_card.dart`, `lib/presentation/ui/widgets/chart/pie_chart.dart` or `lib/presentation/ui/screens/main_screen.dart` — those are BLOCK 12.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/ui/widgets/transaction_dialog_test.dart
flutter analyze
flutter test
```
Expected: the first command exits 0 and reports `+3`; `flutter analyze` exits 0 printing `No issues found!`; `flutter test` exits 0 and reports `All tests passed!` with 296 tests (293 after BLOCK 10, plus 3).

### If verification fails
1. Read the failing output in full.
2. Fix only `lib/presentation/ui/widgets/transaction_dialog.dart` and `test/presentation/ui/widgets/transaction_dialog_test.dart`.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 11's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/ui/widgets/transaction_dialog.dart test/presentation/ui/widgets/transaction_dialog_test.dart PLAN.md
   git commit -m "Offer user-created categories and creation in the transaction dropdown"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

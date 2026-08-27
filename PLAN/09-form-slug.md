## BLOCK 9 — Replace the two form category fields with one slug

**Depends on:** BLOCK 8 committed
**Touches:** `lib/presentation/viewmodel/transaction_form_viewmodel.dart` (MODIFY), `test/presentation/viewmodel/transaction_form_viewmodel_test.dart` (MODIFY), `lib/presentation/ui/widgets/transaction_dialog.dart` (MODIFY)

3 files: `FormUiState` stops holding two enums and holds one slug string, which is the type a
user-created category can also be; `transaction_dialog.dart` is the only caller of the removed
methods, so it must change in the same commit or the project stops compiling.

### Goal
`TransactionFormViewModel` holds the chosen category as a single `String? categorySlug`, clears
it when the transaction type changes, and the transaction dialog drives it through one
`DropdownButtonFormField<String>` instead of two enum-typed dropdowns.

### Context to read first
1. `lib/presentation/viewmodel/transaction_form_viewmodel.dart` — the whole file (187 lines). Note `enum ExpenseCategory` at line 8 and `enum IncomeCategory` at line 20 stay exactly as they are; only `FormUiState` and the three category members change.
2. `lib/domain/model/transaction.dart:47-48` and `:61-62` — the `int? Function()? endMonth` pattern in `copyWith`, which is how this project makes a nullable field clearable. `categorySlug` uses the same pattern.
3. `lib/presentation/ui/widgets/transaction_dialog.dart:161-313` — `_CategoryAndQuantityInput` and `_CategoryDropdown`, the two widgets this block rewrites. The two branches of `_CategoryDropdown` differ only in their enum, their label mapper and their callback; collapsing them removes that duplication (§7 rule 6).
4. `test/presentation/viewmodel/transaction_form_viewmodel_test.dart` — the whole file (275 lines); every place it names `expenseCategory`, `incomeCategory`, `onExpenseCategoryChange` or `onIncomeCategoryChange` is edited below.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `lib/presentation/viewmodel/transaction_form_viewmodel.dart`, replace the two lines
   ```dart
     final ExpenseCategory? expenseCategory;
     final IncomeCategory? incomeCategory;
   ```
   with:
   ```dart
     /// `.name` of an [ExpenseCategory] or an [IncomeCategory] value, or the
     /// slug of a category the user created. `null` means nothing is chosen.
     final String? categorySlug;
   ```
2. In the same file, in the `FormUiState` constructor, replace the two lines
   ```dart
       this.expenseCategory,
       this.incomeCategory,
   ```
   with:
   ```dart
       this.categorySlug,
   ```
3. In the same file, in the `copyWith` parameter list, replace the two lines
   ```dart
       ExpenseCategory? expenseCategory,
       IncomeCategory? incomeCategory,
   ```
   with:
   ```dart
       String? Function()? categorySlug,
   ```
4. In the same file, in the `copyWith` body, replace the two lines
   ```dart
         expenseCategory: expenseCategory ?? this.expenseCategory,
         incomeCategory: incomeCategory ?? this.incomeCategory,
   ```
   with:
   ```dart
         categorySlug: categorySlug != null ? categorySlug() : this.categorySlug,
   ```
5. In the same file, replace the whole body of the `isSubmitEnabled` getter with:
   ```dart
       final hasValidQuantity =
           _uiState.quantity.isNotEmpty && !_uiState.isQuantityError;
       return hasValidQuantity && _uiState.categorySlug != null;
   ```
6. In the same file, replace the whole `onTransactionTypeChange` method with:
   ```dart
     /// Switching the type clears the chosen category: the two types never offer
     /// the same options, so keeping the old slug would submit a category the
     /// user cannot see in the dropdown.
     void onTransactionTypeChange(TransactionType newType) {
       _uiState = _uiState.copyWith(
         transactionType: newType,
         categorySlug: () => null,
       );
       notifyListeners();
     }
   ```
7. In the same file, replace the two methods `onExpenseCategoryChange` and `onIncomeCategoryChange` — both of them, together with their bodies — with this single method:
   ```dart
     void onCategoryChange(String newCategorySlug) {
       _uiState = _uiState.copyWith(categorySlug: () => newCategorySlug);
       notifyListeners();
     }
   ```
8. In the same file, inside `_submitTransaction`, replace the three lines
   ```dart
       final category = _uiState.transactionType == TransactionType.expense
           ? _uiState.expenseCategory?.name
           : _uiState.incomeCategory?.name;
   ```
   with:
   ```dart
       final category = _uiState.categorySlug;
   ```
9. In `lib/presentation/ui/widgets/transaction_dialog.dart`, replace the three lines inside the `_CategoryAndQuantityInput(...)` call in `TransactionDialog.build`
   ```dart
                     onExpenseCategoryChange: viewModel.onExpenseCategoryChange,
                     onIncomeCategoryChange: viewModel.onIncomeCategoryChange,
                     onQuantityChange: viewModel.onQuantityChange,
   ```
   with:
   ```dart
                     onCategoryChange: viewModel.onCategoryChange,
                     onQuantityChange: viewModel.onQuantityChange,
   ```
10. In the same file, replace everything from the line `class _CategoryAndQuantityInput extends StatelessWidget {` down to the closing brace of `class _CategoryDropdown` — that is the whole of lines 161 to 313 — with:
    ```dart
    class _CategoryAndQuantityInput extends StatelessWidget {
      final FormUiState uiState;
      final void Function(String) onCategoryChange;
      final void Function(String) onQuantityChange;

      const _CategoryAndQuantityInput({
        required this.uiState,
        required this.onCategoryChange,
        required this.onQuantityChange,
      });

      @override
      Widget build(BuildContext context) {
        final l10n = AppLocalizations.of(context)!;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CategoryDropdown(
                transactionType: uiState.transactionType,
                categorySlug: uiState.categorySlug,
                onCategoryChange: onCategoryChange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: l10n.formQuantityLabel,
                  border: const OutlineInputBorder(),
                  errorText: uiState.isQuantityError
                      ? l10n.labelInvalidNumber
                      : null,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
                onChanged: onQuantityChange,
              ),
            ),
          ],
        );
      }
    }

    /// One entry of the category dropdown: the value stored in
    /// `transactions.category`, the text shown, and the icon shown beside it.
    class _CategoryOption {
      final String slug;
      final String label;
      final IconData icon;

      const _CategoryOption({
        required this.slug,
        required this.label,
        required this.icon,
      });
    }

    List<_CategoryOption> _builtInOptions(
      TransactionType type,
      AppLocalizations l10n,
    ) {
      if (type == TransactionType.expense) {
        return ExpenseCategory.values
            .map(
              (category) => _CategoryOption(
                slug: category.name,
                label: mapExpenseCategory(category, l10n),
                icon: category.icon,
              ),
            )
            .toList();
      }

      return IncomeCategory.values
          .map(
            (category) => _CategoryOption(
              slug: category.name,
              label: mapIncomeCategory(category, l10n),
              icon: category.icon,
            ),
          )
          .toList();
    }

    class _CategoryDropdown extends StatelessWidget {
      final TransactionType transactionType;
      final String? categorySlug;
      final void Function(String) onCategoryChange;

      const _CategoryDropdown({
        required this.transactionType,
        required this.categorySlug,
        required this.onCategoryChange,
      });

      @override
      Widget build(BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        final options = _builtInOptions(transactionType, l10n);
        // A slug that is not among the options would trip the dropdown's own
        // assertion, so an unknown one shows as nothing chosen.
        final selected = options.any((option) => option.slug == categorySlug)
            ? categorySlug
            : null;

        return DropdownButtonFormField<String>(
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
          onChanged: (value) {
            if (value != null) onCategoryChange(value);
          },
        );
      }
    }
    ```
11. In `test/presentation/viewmodel/transaction_form_viewmodel_test.dart`, replace the two lines
    ```dart
            expect(state.expenseCategory, isNull);
            expect(state.incomeCategory, isNull);
    ```
    with the single line, in both places they appear (inside `should start with an empty list of items` and inside `should reset all fields`):
    ```dart
            expect(state.categorySlug, isNull);
    ```
12. In the same file, replace the two groups `onExpenseCategoryChange` and `onIncomeCategoryChange` — that is lines 70 to 84 in the file before this block — with:
    ```dart
        group('onCategoryChange', () {
          test('should change the category slug', () {
            viewModel.onCategoryChange('food');

            expect(viewModel.uiState.categorySlug, equals('food'));
          });

          test('should accept a user-created slug', () {
            viewModel.onCategoryChange('custom_mercado');

            expect(viewModel.uiState.categorySlug, equals('custom_mercado'));
          });
        });
    ```
13. In the same file, replace every remaining occurrence of
    ```dart
    viewModel.onExpenseCategoryChange(ExpenseCategory.food);
    ```
    with:
    ```dart
    viewModel.onCategoryChange('food');
    ```
    and every remaining occurrence of
    ```dart
    viewModel.onIncomeCategoryChange(IncomeCategory.salary);
    ```
    with:
    ```dart
    viewModel.onCategoryChange('salary');
    ```
14. In the same file, replace the line
    ```dart
            expect(viewModel.uiState.expenseCategory, isNull);
    ```
    inside the `should reset form after successful submit` test with:
    ```dart
            expect(viewModel.uiState.categorySlug, isNull);
    ```
15. In the same file, immediately after the closing `});` of the `onCategoryChange` group added in step 12, insert:
    ```dart

        group('onTransactionTypeChange clearing', () {
          test('should clear the category slug when the type changes', () {
            viewModel.onCategoryChange('food');

            viewModel.onTransactionTypeChange(TransactionType.income);

            expect(viewModel.uiState.categorySlug, isNull);
            expect(viewModel.isSubmitEnabled, isFalse);
          });
        });
    ```
16. In the same file, inside the `submitCommand` group, immediately after the closing `});` of the `should create transaction with correct data via Command` test, insert:
    ```dart

        test('should submit the user-created slug in the category field', () async {
          when(
            () => mockMakeTransactionUseCase(any()),
          ).thenAnswer((_) async => Result.ok(1));

          viewModel.onCategoryChange('custom_mercado');
          viewModel.onQuantityChange('12.00');

          await viewModel.submitCommand.execute(2, 2026);

          final captured =
              verify(
                    () => mockMakeTransactionUseCase(captureAny()),
                  ).captured.single
                  as Transaction;
          expect(captured.category, equals('custom_mercado'));
        });
    ```
17. Run the §5 `write-only` formatter on the Touches paths only:
    ```
    dart format lib/presentation/viewmodel/transaction_form_viewmodel.dart test/presentation/viewmodel/transaction_form_viewmodel_test.dart lib/presentation/ui/widgets/transaction_dialog.dart
    ```

### Do not
- Do not delete `enum ExpenseCategory` or `enum IncomeCategory`, and do not move them out of `lib/presentation/viewmodel/transaction_form_viewmodel.dart`. `category_icon.dart`, `category_color.dart` and `category_mapper.dart` import them from there.
- Do not add a `String? expenseCategorySlug` plus a `String? incomeCategorySlug`. One field, cleared on type change, is the whole point of this block.
- Do not add the user-created categories or a `+ Nova categoria` entry to the dropdown here — that is BLOCK 11. After this block the dropdown still shows only the 13 built-in options.
- Do not make `_CategoryDropdown` read a `Provider`; it takes its data as parameters until BLOCK 11 gives it the custom list.
- Do not touch `lib/presentation/ui/widgets/transaction_card.dart` or `lib/presentation/ui/widgets/chart/pie_chart.dart` — those are BLOCK 12.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/viewmodel/transaction_form_viewmodel_test.dart
flutter analyze
flutter test
```
Expected: the first command exits 0 and reports `+27` (25 before this block, minus the 2 removed single-test groups, plus 2 in the new `onCategoryChange` group, plus 1 from step 15, plus 1 from step 16); `flutter analyze` exits 0 printing `No issues found!`; `flutter test` exits 0 and reports `All tests passed!` with 287 tests (285 after BLOCK 8, plus 2).

### If verification fails
1. Read the failing output in full.
2. Fix only `lib/presentation/viewmodel/transaction_form_viewmodel.dart`, `test/presentation/viewmodel/transaction_form_viewmodel_test.dart` and `lib/presentation/ui/widgets/transaction_dialog.dart`.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 9's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/viewmodel/transaction_form_viewmodel.dart test/presentation/viewmodel/transaction_form_viewmodel_test.dart lib/presentation/ui/widgets/transaction_dialog.dart PLAN.md
   git commit -m "Hold the chosen category as one slug in the transaction form"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

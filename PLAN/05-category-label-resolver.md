## BLOCK 5 — Add the category label resolver

**Depends on:** BLOCK 4 committed
**Touches:** `lib/presentation/ui/utils/category_mapper.dart` (MODIFY), `test/presentation/ui/utils/category_mapper_test.dart` (MODIFY)

### Goal
`getExpenseCategoryLabel(String?, AppLocalizations)` returns the localized name of an expense
category, and `l10n.categoryUncategorized` for `null` or an unknown string.

### Context to read first
1. `lib/presentation/ui/utils/category_mapper.dart` — the whole file (37 lines); `mapExpenseCategory(ExpenseCategory, AppLocalizations)` already returns the localized name for an enum value and is the function the new resolver delegates to.
2. `lib/presentation/ui/utils/category_icon.dart:31-49` — `getCategoryIcon`, the `String?` resolver shape to mirror: null guard first, then `.where((e) => e.name == category).firstOrNull`, then a fallback.
3. `test/presentation/ui/utils/category_mapper_test.dart` — the whole file; the new tests join it in the same style.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `lib/presentation/ui/utils/category_mapper.dart`, append at the end of the file:
   ```dart

   /// Resolves the localized expense category name from a [String] category
   /// (used by the `Transaction` model). Delegates to [mapExpenseCategory].
   /// A null or unknown value falls back to the "no category" label.
   String getExpenseCategoryLabel(String? category, AppLocalizations l10n) {
     if (category == null) {
       return l10n.categoryUncategorized;
     }

     final parsed = ExpenseCategory.values
         .where((e) => e.name == category)
         .firstOrNull;
     return parsed == null
         ? l10n.categoryUncategorized
         : mapExpenseCategory(parsed, l10n);
   }
   ```
2. In `test/presentation/ui/utils/category_mapper_test.dart`, add a new
   `group('getExpenseCategoryLabel', ...)` as the last statement inside `main()`. It uses the
   file's existing `late AppLocalizations l10n;` variable, which `setUp()` already assigns
   `AppLocalizationsEn()`. It holds exactly 3 test cases:
   - `'should return the localized name for a known category'` — call `getExpenseCategoryLabel('food', l10n)` and expect it equals `mapExpenseCategory(ExpenseCategory.food, l10n)`.
   - `'should return the uncategorized label when the category is null'` — call `getExpenseCategoryLabel(null, l10n)` and expect it equals `l10n.categoryUncategorized`.
   - `'should return the uncategorized label for an unknown string'` — call `getExpenseCategoryLabel('not-a-category', l10n)` and expect it equals `l10n.categoryUncategorized`.
3. Format the two files:
   ```
   dart format lib/presentation/ui/utils/category_mapper.dart test/presentation/ui/utils/category_mapper_test.dart
   ```

### Do not
- Do not add a `getIncomeCategoryLabel` — §3 puts income out of scope and there would be no caller.
- Do not change `mapExpenseCategory` or `mapIncomeCategory`; the new function wraps the first one and both keep their current signature (§9: no silent contract change).
- Do not duplicate the nine `l10n.expenseCategory*` lookups inside the new function.
- Do not run `dart format` on any path other than the two named in step 3.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/ui/utils/category_mapper_test.dart
flutter analyze
```
Expected: the first command exits 0 and prints `+18: All tests passed!` (15 before this block
plus 3 new); `flutter analyze` exits 0 printing `No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 5's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/ui/utils/category_mapper.dart test/presentation/ui/utils/category_mapper_test.dart PLAN.md
   git commit -m "Resolve expense category labels from the stored string"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

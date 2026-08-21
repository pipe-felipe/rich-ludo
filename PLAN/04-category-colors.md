## BLOCK 4 — Add category colors and their resolver

**Depends on:** BLOCK 3 committed
**Touches:** `lib/presentation/ui/theme/app_colors.dart` (MODIFY), `lib/presentation/ui/utils/category_color.dart` (NEW), `test/presentation/ui/utils/category_color_test.dart` (NEW)

### Goal
`getExpenseCategoryColor(String?)` returns one distinct constant color per `ExpenseCategory`
value and a grey for `null` or an unknown string, with every color declared in
`lib/presentation/ui/theme/app_colors.dart`.

### Context to read first
1. `lib/presentation/ui/utils/category_icon.dart` — the whole file (51 lines); the pattern to mirror exactly: an `extension <Enum><Thing> on <Enum>` with an exhaustive `switch (this)` expression, then a top-level resolver taking `String?` that parses the enum by `.name` with `.where(...).firstOrNull` and falls back to a private default.
2. `lib/presentation/ui/theme/app_colors.dart:57-61` — the `PiColors` class of shared constants; the new class is added below it in the same style (`static const name = Color(0xFF......);`).
3. `lib/presentation/viewmodel/transaction_form_viewmodel.dart:8-18` — the 9 `ExpenseCategory` values, in declaration order.
4. `test/presentation/ui/utils/category_icon_test.dart` — the test style to mirror: a `Map<Enum, Expected>` fixture, a test asserting the map covers `Enum.values.length`, a loop generating one test per value, and separate groups for the `String?` resolver's null and unknown cases.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `lib/presentation/ui/theme/app_colors.dart`, append at the end of the file:
   ```dart

   /// Cores das fatias do gráfico de despesas por categoria.
   /// Tons médios do Material, legíveis sobre o fundo claro e o escuro,
   /// e escuros o bastante para o rótulo branco das fatias.
   class CategoryPiColors {
     static const transport = Color(0xFF1E88E5);
     static const gift = Color(0xFFD81B60);
     static const recurring = Color(0xFF6D4C41);
     static const food = Color(0xFFF4511E);
     static const stuff = Color(0xFF8E24AA);
     static const medicine = Color(0xFF00897B);
     static const clothes = Color(0xFF3949AB);
     static const hygiene = Color(0xFF00ACC1);
     static const care = Color(0xFF7CB342);
     static const uncategorized = Color(0xFF757575);
   }
   ```
2. Create `lib/presentation/ui/utils/category_color.dart` with exactly this content:
   ```dart
   import 'package:flutter/material.dart';

   import '../../viewmodel/transaction_form_viewmodel.dart';
   import '../theme/app_colors.dart';

   /// Exhaustive color mapping for [ExpenseCategory].
   extension ExpenseCategoryColor on ExpenseCategory {
     Color get color => switch (this) {
       ExpenseCategory.transport => CategoryPiColors.transport,
       ExpenseCategory.gift => CategoryPiColors.gift,
       ExpenseCategory.recurring => CategoryPiColors.recurring,
       ExpenseCategory.food => CategoryPiColors.food,
       ExpenseCategory.stuff => CategoryPiColors.stuff,
       ExpenseCategory.medicine => CategoryPiColors.medicine,
       ExpenseCategory.clothes => CategoryPiColors.clothes,
       ExpenseCategory.hygiene => CategoryPiColors.hygiene,
       ExpenseCategory.care => CategoryPiColors.care,
     };
   }

   /// Resolves the chart slice color from a [String] category
   /// (used by the `Transaction` model). Delegates to the exhaustive
   /// enum extension above.
   Color getExpenseCategoryColor(String? category) {
     if (category == null) {
       return CategoryPiColors.uncategorized;
     }

     final parsed = ExpenseCategory.values
         .where((e) => e.name == category)
         .firstOrNull;
     return parsed?.color ?? CategoryPiColors.uncategorized;
   }
   ```
3. Create `test/presentation/ui/utils/category_color_test.dart`, mirroring
   `test/presentation/ui/utils/category_icon_test.dart`, with:
   - `group('ExpenseCategoryColor', ...)` holding a `const expectedColors = <ExpenseCategory, Color>{...}` fixture with all 9 pairs from step 1, a test `'should map all enum values'` asserting `expectedColors.length` equals `ExpenseCategory.values.length`, and a loop over `expectedColors.entries` generating one test per value named `'should return ${entry.value} for ${entry.key.name}'`.
   - `group('getExpenseCategoryColor', ...)` with a loop over `ExpenseCategory.values` generating one test each named `'should return the correct color for "${category.name}"'`, plus 2 more tests: `'should return the uncategorized color when the category is null'` and `'should return the uncategorized color for an unknown string'` (pass `'not-a-category'`).
   - A test `'should give every expense category a distinct color'` asserting `expectedColors.values.toSet().length` equals `9`.
4. Format the three files:
   ```
   dart format lib/presentation/ui/theme/app_colors.dart lib/presentation/ui/utils/category_color.dart test/presentation/ui/utils/category_color_test.dart
   ```

### Do not
- Do not add an `IncomeCategoryColor` extension or income color constants — §9 and §3 forbid it.
- Do not add per-theme variants (`DarkPiColors` / `LightPiColors` entries) or an `AppTheme.categoryColor(context)` helper. One shared palette is the decision; a second one is duplication (§7 rule 3).
- Do not change any existing color constant in `lib/presentation/ui/theme/app_colors.dart`.
- Do not use `Theme.of(context)` in `category_color.dart`; the resolver takes no `BuildContext`, exactly like `getCategoryIcon`.
- Do not run `dart format` on any path other than the three named in step 4.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/ui/utils/category_color_test.dart
flutter analyze
```
Expected: the first command exits 0 and prints `+22: All tests passed!` (1 coverage test + 9
extension tests + 9 resolver tests + 2 fallback tests + 1 distinctness test); `flutter analyze`
exits 0 printing `No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 4's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/ui/theme/app_colors.dart lib/presentation/ui/utils/category_color.dart test/presentation/ui/utils/category_color_test.dart PLAN.md
   git commit -m "Add expense category chart colors"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

## BLOCK 8 — Resolve icon, color and label for user-created slugs

**Depends on:** BLOCK 7 committed
**Touches:** `lib/presentation/ui/theme/app_colors.dart` (MODIFY), `lib/presentation/ui/utils/category_icon.dart` (MODIFY), `lib/presentation/ui/utils/category_color.dart` (MODIFY), `lib/presentation/ui/utils/category_mapper.dart` (MODIFY), `test/presentation/ui/utils/category_icon_test.dart` (MODIFY), `test/presentation/ui/utils/category_color_test.dart` (MODIFY), `test/presentation/ui/utils/category_mapper_test.dart` (MODIFY)

7 files: the three resolution helpers take the identical new parameter and each has one mirrored
test file; the palette they resolve against lives in `app_colors.dart`. Splitting this would
leave the app with two of three helpers aware of user-created categories, which renders a
transaction with the right icon and the wrong label.

### Goal
`getCategoryIcon`, `getExpenseCategoryColor` and `getExpenseCategoryLabel` return a user-created
category's stored icon, color and name when the passed slug matches one, and behave exactly as
before for every built-in name, for `null`, and for an unknown string.

### Context to read first
1. `lib/presentation/ui/utils/category_icon.dart` — the whole file (51 lines); the two exhaustive enum extensions stay untouched, and `getCategoryIcon` at line 32 is the function this block extends.
2. `lib/presentation/ui/utils/category_color.dart` — the whole file (33 lines); same shape, `getExpenseCategoryColor` at line 24.
3. `lib/presentation/ui/utils/category_mapper.dart` — the whole file (54 lines); same shape, `getExpenseCategoryLabel` at line 43.
4. `lib/presentation/ui/theme/app_colors.dart:63-77` — `CategoryPiColors`, and its doc comment stating the slice colors must be dark enough for white slice labels; the new palette follows that rule.
5. `test/presentation/ui/utils/category_icon_test.dart` — the whole file (101 lines); the test style to mirror: a `Map` of expectations, a `should map all enum values` length check, then one generated test per entry.
6. §9 Quality bars — the first bar forbids building `IconData` from a stored integer; the second forbids `Color.value`.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `lib/presentation/ui/theme/app_colors.dart`, immediately after the line `  static const uncategorized = Color(0xFF757575);` and before the closing brace of `CategoryPiColors`, insert:
   ```dart

   /// Colors offered when the user creates a category. Material 800 tones,
   /// distinct from the nine built-in slice colors above and dark enough for
   /// the white slice labels.
   static const List<Color> customPalette = [
     Color(0xFFC62828),
     Color(0xFFAD1457),
     Color(0xFF6A1B9A),
     Color(0xFF4527A0),
     Color(0xFF283593),
     Color(0xFF1565C0),
     Color(0xFF00838F),
     Color(0xFF00695C),
     Color(0xFF2E7D32),
     Color(0xFF558B2F),
     Color(0xFFEF6C00),
     Color(0xFF4E342E),
   ];
   ```
2. In `lib/presentation/ui/utils/category_icon.dart`, add this import immediately after `import 'package:flutter/material.dart';`:
   ```dart

   import '../../../domain/model/custom_category.dart';
   ```
3. In the same file, immediately after the closing brace of the `IncomeCategoryIcon` extension and before the doc comment of `getCategoryIcon`, insert:
   ```dart

   /// Icons the user may pick when creating a category.
   ///
   /// The list is fixed and `const` on purpose: `flutter build apk --release`
   /// tree-shakes the Material icon font down to the icons it can see at
   /// compile time. Building an `IconData` from a stored code point at runtime
   /// would make the picked icon render as a blank box in a release build.
   const List<IconData> customCategoryIcons = [
     Icons.label,
     Icons.shopping_cart,
     Icons.home,
     Icons.pets,
     Icons.school,
     Icons.fitness_center,
     Icons.local_bar,
     Icons.local_cafe,
     Icons.flight,
     Icons.hotel,
     Icons.sports_esports,
     Icons.movie,
     Icons.music_note,
     Icons.book,
     Icons.build,
     Icons.computer,
     Icons.phone_android,
     Icons.wifi,
     Icons.bolt,
     Icons.water_drop,
     Icons.local_gas_station,
     Icons.savings,
     Icons.credit_card,
     Icons.child_care,
   ];

   /// Resolves a stored `iconCodePoint` back to its `const` entry of
   /// [customCategoryIcons]. A code point that is not in the list falls back to
   /// the first entry, so a row written by a future version still renders.
   IconData resolveCustomCategoryIcon(int codePoint) {
     for (final icon in customCategoryIcons) {
       if (icon.codePoint == codePoint) return icon;
     }
     return customCategoryIcons.first;
   }
   ```
4. In the same file, replace the whole `getCategoryIcon` function — its doc comment stays, its signature and body change — with:
   ```dart
   /// Resolves icon from a [String] category (used by [Transaction] model).
   /// Delegates to the exhaustive enum extensions above, or to
   /// [resolveCustomCategoryIcon] when [category] is a user-created slug.
   IconData getCategoryIcon(
     String? category, {
     required bool isIncome,
     List<CustomCategory> customCategories = const [],
   }) {
     if (category == null) {
       return _defaultIcon(isIncome);
     }

     final custom = customCategories
         .where((entry) => entry.slug == category)
         .firstOrNull;
     if (custom != null) {
       return resolveCustomCategoryIcon(custom.iconCodePoint);
     }

     if (isIncome) {
       final parsed = IncomeCategory.values
           .where((e) => e.name == category)
           .firstOrNull;
       return parsed?.icon ?? _defaultIcon(true);
     }

     final parsed = ExpenseCategory.values
         .where((e) => e.name == category)
         .firstOrNull;
     return parsed?.icon ?? _defaultIcon(false);
   }
   ```
5. In `lib/presentation/ui/utils/category_color.dart`, add this import immediately after `import 'package:flutter/material.dart';`:
   ```dart

   import '../../../domain/model/custom_category.dart';
   ```
6. In the same file, replace the whole `getExpenseCategoryColor` function — its doc comment stays, its signature and body change — with:
   ```dart
   /// Resolves the chart slice color from a [String] category
   /// (used by the `Transaction` model). Delegates to the exhaustive
   /// enum extension above, or to the stored color of a user-created slug.
   Color getExpenseCategoryColor(
     String? category, {
     List<CustomCategory> customCategories = const [],
   }) {
     if (category == null) {
       return CategoryPiColors.uncategorized;
     }

     final custom = customCategories
         .where((entry) => entry.slug == category)
         .firstOrNull;
     if (custom != null) {
       return Color(custom.colorValue);
     }

     final parsed = ExpenseCategory.values
         .where((e) => e.name == category)
         .firstOrNull;
     return parsed?.color ?? CategoryPiColors.uncategorized;
   }
   ```
7. In `lib/presentation/ui/utils/category_mapper.dart`, add this import immediately after `import '../../../l10n/app_localizations.dart';`:
   ```dart
   import '../../../domain/model/custom_category.dart';
   ```
8. In the same file, replace the whole `getExpenseCategoryLabel` function — its doc comment stays, its signature and body change — with:
   ```dart
   /// Resolves the localized expense category name from a [String] category
   /// (used by the `Transaction` model). Delegates to [mapExpenseCategory].
   /// A user-created slug resolves to its stored name, which the user typed and
   /// which is therefore not localized. A null or unknown value falls back to
   /// the "no category" label.
   String getExpenseCategoryLabel(
     String? category,
     AppLocalizations l10n, {
     List<CustomCategory> customCategories = const [],
   }) {
     if (category == null) {
       return l10n.categoryUncategorized;
     }

     final custom = customCategories
         .where((entry) => entry.slug == category)
         .firstOrNull;
     if (custom != null) {
       return custom.name;
     }

     final parsed = ExpenseCategory.values
         .where((e) => e.name == category)
         .firstOrNull;
     return parsed == null
         ? l10n.categoryUncategorized
         : mapExpenseCategory(parsed, l10n);
   }
   ```
9. In `test/presentation/ui/utils/category_icon_test.dart`, add these two imports after `import 'package:flutter/material.dart';`:
   ```dart
   import 'package:rich_ludo/domain/model/custom_category.dart';
   import 'package:rich_ludo/domain/model/transaction_type.dart';
   ```
10. In the same file, immediately before the final closing `}` of `main()`, insert these 6 tests:
    ```dart

      group('customCategoryIcons', () {
        test('should offer 24 icons', () {
          expect(customCategoryIcons, hasLength(24));
        });

        test('should give every entry a distinct code point', () {
          final codePoints = customCategoryIcons
              .map((icon) => icon.codePoint)
              .toSet();

          expect(codePoints, hasLength(customCategoryIcons.length));
        });
      });

      group('resolveCustomCategoryIcon', () {
        test('should return the matching const icon', () {
          expect(
            resolveCustomCategoryIcon(Icons.shopping_cart.codePoint),
            equals(Icons.shopping_cart),
          );
        });

        test('should return the first icon for an unknown code point', () {
          expect(resolveCustomCategoryIcon(1), equals(customCategoryIcons.first));
        });
      });

      group('getCategoryIcon with user-created categories', () {
        const custom = CustomCategory(
          id: 1,
          slug: 'custom_mercado',
          name: 'Mercado',
          type: TransactionType.expense,
          iconCodePoint: 0xe59c,
          colorValue: 0xFFC62828,
        );

        test('should return the stored icon for a user-created slug', () {
          expect(
            getCategoryIcon(
              'custom_mercado',
              isIncome: false,
              customCategories: const [custom],
            ),
            equals(Icons.shopping_cart),
          );
        });

        test('should still resolve a built-in name when a custom list is given', () {
          expect(
            getCategoryIcon(
              'food',
              isIncome: false,
              customCategories: const [custom],
            ),
            equals(ExpenseCategory.food.icon),
          );
        });
      });
    ```
11. In `test/presentation/ui/utils/category_color_test.dart`, add these two imports after `import 'package:flutter/material.dart';`:
    ```dart
    import 'package:rich_ludo/domain/model/custom_category.dart';
    import 'package:rich_ludo/domain/model/transaction_type.dart';
    ```
12. In the same file, immediately before the final closing `}` of `main()`, insert these 4 tests:
    ```dart

      group('CategoryPiColors.customPalette', () {
        test('should offer 12 colors', () {
          expect(CategoryPiColors.customPalette, hasLength(12));
        });

        test('should give every entry a distinct value', () {
          expect(CategoryPiColors.customPalette.toSet(), hasLength(12));
        });
      });

      group('getExpenseCategoryColor with user-created categories', () {
        const custom = CustomCategory(
          id: 1,
          slug: 'custom_mercado',
          name: 'Mercado',
          type: TransactionType.expense,
          iconCodePoint: 0xe59c,
          colorValue: 0xFFC62828,
        );

        test('should return the stored color for a user-created slug', () {
          expect(
            getExpenseCategoryColor(
              'custom_mercado',
              customCategories: const [custom],
            ),
            equals(const Color(0xFFC62828)),
          );
        });

        test('should still resolve a built-in name when a custom list is given', () {
          expect(
            getExpenseCategoryColor('food', customCategories: const [custom]),
            equals(ExpenseCategory.food.color),
          );
        });
      });
    ```
13. In `test/presentation/ui/utils/category_mapper_test.dart`, add these two imports after `import 'package:flutter_test/flutter_test.dart';`:
    ```dart
    import 'package:rich_ludo/domain/model/custom_category.dart';
    import 'package:rich_ludo/domain/model/transaction_type.dart';
    ```
14. In the same file, immediately before the final closing `}` of `main()`, insert these 3 tests:
    ```dart

      group('getExpenseCategoryLabel with user-created categories', () {
        const custom = CustomCategory(
          id: 1,
          slug: 'custom_mercado',
          name: 'Mercado',
          type: TransactionType.expense,
          iconCodePoint: 0xe59c,
          colorValue: 0xFFC62828,
        );

        test('should return the stored name for a user-created slug', () {
          expect(
            getExpenseCategoryLabel(
              'custom_mercado',
              l10n,
              customCategories: const [custom],
            ),
            equals('Mercado'),
          );
        });

        test('should still resolve a built-in name when a custom list is given', () {
          expect(
            getExpenseCategoryLabel('food', l10n, customCategories: const [custom]),
            equals(mapExpenseCategory(ExpenseCategory.food, l10n)),
          );
        });

        test('should fall back to uncategorized for a deleted user slug', () {
          expect(
            getExpenseCategoryLabel('custom_removida', l10n, customCategories: const []),
            equals(l10n.categoryUncategorized),
          );
        });
      });
    ```
15. Run the §5 `write-only` formatter on the Touches paths only. `test/presentation/ui/utils/category_icon_test.dart` is one of the 7 files §6 records as already unformatted, so this step reformats parts of it that this block did not edit — that is expected and belongs in this block's commit:
    ```
    dart format lib/presentation/ui/theme/app_colors.dart lib/presentation/ui/utils/category_icon.dart lib/presentation/ui/utils/category_color.dart lib/presentation/ui/utils/category_mapper.dart test/presentation/ui/utils/category_icon_test.dart test/presentation/ui/utils/category_color_test.dart test/presentation/ui/utils/category_mapper_test.dart
    ```

### Do not
- Do not write `IconData(custom.iconCodePoint)` anywhere. §9 explains what it breaks; `resolveCustomCategoryIcon` is the only way to turn a stored code point into an icon.
- Do not write `Color.value` or `color.value` anywhere; §9 forbids it and `flutter analyze` fails on it.
- Do not add or remove a value of `ExpenseCategory`, `IncomeCategory`, `ExpenseCategoryIcon`, `IncomeCategoryIcon`, `ExpenseCategoryColor`, `mapExpenseCategory` or `mapIncomeCategory`, and do not change an existing test in the three test files.
- Do not make `customCategories` a required parameter. The default `const []` is what keeps every current call site compiling; BLOCK 11 and BLOCK 12 replace those defaults with the real list.
- Do not add an income colour helper. The pie chart is expenses-only, so `getExpenseCategoryColor` stays the only colour resolver.
- Do not touch any widget file — those are BLOCK 11 and BLOCK 12.

### Verify
Run from the repository root, in this order:
```
flutter test test/presentation/ui/utils/
flutter analyze
flutter test
```
Expected: the first command exits 0 and reports `+85` (72 existing plus 13 new: 6 from step 10, 4 from step 12, 3 from step 14); `flutter analyze` exits 0 printing `No issues found!`; `flutter test` exits 0 and reports `All tests passed!` with 285 tests (272 after BLOCK 7, plus 13).

### If verification fails
1. Read the failing output in full.
2. Fix only the seven files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 8's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/presentation/ui/theme/app_colors.dart lib/presentation/ui/utils/category_icon.dart lib/presentation/ui/utils/category_color.dart lib/presentation/ui/utils/category_mapper.dart test/presentation/ui/utils/category_icon_test.dart test/presentation/ui/utils/category_color_test.dart test/presentation/ui/utils/category_mapper_test.dart PLAN.md
   git commit -m "Resolve icon, color and label for user-created categories"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

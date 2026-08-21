## BLOCK 2 — Add the `CategoryTotal` value object

**Depends on:** BLOCK 1 committed
**Touches:** `lib/domain/model/category_total.dart` (NEW), `test/domain/model/category_total_test.dart` (NEW)

### Goal
`CategoryTotal` exists as an immutable domain model with `copyWith()`, `operator ==` and
`hashCode`, and its unit test passes.

### Context to read first
1. `lib/domain/model/transaction.dart` — the whole file (101 lines); the pattern to mirror: `final` fields, a `const` constructor with named parameters, `copyWith()` that takes `int? Function()?` for nullable fields, `operator ==` with an `identical` guard, and `hashCode` built with `Object.hash`.
2. `test/domain/model/transaction_test.dart` — the test style to mirror: English `test('should ...')` names, `group()` per concern, direct construction without mocks.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Create `lib/domain/model/category_total.dart` with exactly this content:
   ```dart
   /// One slice of the expenses-by-category chart.
   ///
   /// [category] holds the `.name` of an `ExpenseCategory`, or `null` for
   /// transactions saved without a category.
   class CategoryTotal {
     final String? category;
     final int amountCents;

     const CategoryTotal({required this.category, required this.amountCents});

     CategoryTotal copyWith({
       String? Function()? category,
       int? amountCents,
     }) {
       return CategoryTotal(
         category: category != null ? category() : this.category,
         amountCents: amountCents ?? this.amountCents,
       );
     }

     @override
     bool operator ==(Object other) {
       if (identical(this, other)) return true;
       return other is CategoryTotal &&
           other.category == category &&
           other.amountCents == amountCents;
     }

     @override
     int get hashCode => Object.hash(category, amountCents);
   }
   ```
2. Create `test/domain/model/category_total_test.dart` with exactly 5 test cases inside
   `group('CategoryTotal', ...)`, following the style of `test/domain/model/transaction_test.dart`:
   - `'should create a category total with the given values'` — build `CategoryTotal(category: 'food', amountCents: 1500)`, expect `category` equals `'food'` and `amountCents` equals `1500`.
   - `'should accept a null category'` — build `CategoryTotal(category: null, amountCents: 200)`, expect `category` is `null`.
   - `'copyWith should change only the given field'` — from `CategoryTotal(category: 'food', amountCents: 1500)`, call `copyWith(amountCents: 900)`, expect `category` still `'food'` and `amountCents` equals `900`.
   - `'copyWith should set the category to null'` — from `CategoryTotal(category: 'food', amountCents: 1500)`, call `copyWith(category: () => null)`, expect `category` is `null` and `amountCents` equals `1500`.
   - `'equality should hold for equal values and fail for different ones'` — expect `CategoryTotal(category: 'food', amountCents: 1500)` equals another instance with the same values and that both have the same `hashCode`; expect it does not equal `CategoryTotal(category: 'food', amountCents: 1501)`.
3. Format the two files:
   ```
   dart format lib/domain/model/category_total.dart test/domain/model/category_total_test.dart
   ```

### Do not
- Do not add a `percentage` field, a `label` field, or a `Color` field. The percentage is computed in BLOCK 7 from the month total, and colors and labels are resolved by BLOCK 4 and BLOCK 5.
- Do not add a `toMap`/`fromMap` mapper. This model is never persisted; `lib/domain/model/transaction_mapper.dart` exists only for stored rows.
- Do not import anything into `lib/domain/model/category_total.dart`. Domain models here import only what they use, and this one uses nothing.
- Do not run `dart format` on any path other than the two named in step 3 (§6 records 8 pre-existing unformatted files).

### Verify
Run from the repository root, in this order:
```
flutter test test/domain/model/category_total_test.dart
flutter analyze
```
Expected: the first command exits 0 and reports `+5` with `All tests passed!`; `flutter analyze`
exits 0 printing `No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 2's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/domain/model/category_total.dart test/domain/model/category_total_test.dart PLAN.md
   git commit -m "Add CategoryTotal domain model"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

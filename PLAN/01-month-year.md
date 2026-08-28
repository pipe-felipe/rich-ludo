## BLOCK 1 — Add the MonthYear domain model

**Depends on:** none
**Touches:** `lib/domain/model/month_year.dart` (NEW), `test/domain/model/month_year_test.dart` (NEW)

### Goal
`MonthYear` exists as an immutable domain value with `next`, `previous`, `isAfter`, `isBefore`,
`compareTo`, `==` and `hashCode`, covered by its own unit test file.

### Context to read first
1. `lib/domain/model/category_total.dart` — the pattern to mirror: a small immutable model, `const` constructor, `copyWith`, `==` and `hashCode` built with `Object.hash`, no imports beyond what it uses.
2. `lib/domain/usecase/delete_recurring_transaction_usecase.dart:114-136` — the five private helpers `_isSingleMonth`, `_isAfter`, `_isBefore`, `_nextMonth`, `_previousMonth`. `MonthYear` replaces the arithmetic in four of them. BLOCK 3 deletes them.
3. `test/domain/model/category_total_test.dart` — the unit test style to mirror: one `group` named after the class, `test('should ...')` names in English.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Create `lib/domain/model/month_year.dart` with exactly this content:
   ```dart
   /// An immutable (month, year) pair with the arithmetic the recurring rules
   /// need: one step in each direction, and ordering against another pair.
   ///
   /// [month] is 1 to 12, matching `Transaction.targetMonth`.
   class MonthYear implements Comparable<MonthYear> {
     final int month;
     final int year;

     const MonthYear(this.month, this.year);

     MonthYear get next =>
         month == 12 ? MonthYear(1, year + 1) : MonthYear(month + 1, year);

     MonthYear get previous =>
         month == 1 ? MonthYear(12, year - 1) : MonthYear(month - 1, year);

     bool isAfter(MonthYear other) => compareTo(other) > 0;

     bool isBefore(MonthYear other) => compareTo(other) < 0;

     @override
     int compareTo(MonthYear other) {
       return year != other.year
           ? year.compareTo(other.year)
           : month.compareTo(other.month);
     }

     @override
     bool operator ==(Object other) {
       if (identical(this, other)) return true;
       return other is MonthYear && other.month == month && other.year == year;
     }

     @override
     int get hashCode => Object.hash(month, year);

     @override
     String toString() => 'MonthYear($month, $year)';
   }
   ```
2. Create `test/domain/model/month_year_test.dart` with one `group('MonthYear', ...)` holding exactly 8 test cases:
   - `'next should advance the month inside the same year'` — `const MonthYear(3, 2026).next` equals `const MonthYear(4, 2026)`.
   - `'next should roll December into January of the following year'` — `const MonthYear(12, 2026).next` equals `const MonthYear(1, 2027)`.
   - `'previous should step back inside the same year'` — `const MonthYear(3, 2026).previous` equals `const MonthYear(2, 2026)`.
   - `'previous should roll January into December of the previous year'` — `const MonthYear(1, 2026).previous` equals `const MonthYear(12, 2025)`.
   - `'isAfter should compare the year before the month'` — `const MonthYear(1, 2027).isAfter(const MonthYear(12, 2026))` is `isTrue`, and `const MonthYear(12, 2026).isAfter(const MonthYear(1, 2027))` is `isFalse`.
   - `'isBefore should compare the year before the month'` — `const MonthYear(12, 2026).isBefore(const MonthYear(1, 2027))` is `isTrue`, and `const MonthYear(1, 2027).isBefore(const MonthYear(12, 2026))` is `isFalse`.
   - `'isAfter and isBefore should both be false for the same pair'` — both calls on `const MonthYear(6, 2026)` against itself are `isFalse`.
   - `'equality should hold for equal values and fail for different ones'` — `const MonthYear(6, 2026)` equals `const MonthYear(6, 2026)`, their `hashCode` values match, and it does not equal `const MonthYear(7, 2026)`.
3. Run the §5 write-only formatter on this block's paths only:
   ```
   dart format lib/domain/model/month_year.dart test/domain/model/month_year_test.dart
   ```

### Do not
- Do not add `copyWith`, a `fromTransaction` constructor, a `DateTime` conversion, or a range type. This block has two consumers and they need only what step 1 lists.
- Do not touch `lib/domain/usecase/delete_recurring_transaction_usecase.dart` — that is BLOCK 3.
- Do not put `MonthYear` inside an existing model file; §7 rule 1 keeps one domain model per file.

### Verify
Run from the repository root, in this order:
```
flutter test test/domain/model/month_year_test.dart
flutter analyze
```
Expected: the first command exits 0 and reports `+8` passing tests; the second exits 0 and prints
`No issues found!`.

### If verification fails
1. Read the failing output in full.
2. Fix only files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 1's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/domain/model/month_year.dart test/domain/model/month_year_test.dart PLAN.md
   git commit -m "Add the MonthYear domain model"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

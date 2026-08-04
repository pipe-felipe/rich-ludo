# Test map

## Existing coverage

| Area | Test location | Coverage |
|---|---|---|
| Models | `test/domain/model/transaction_test.dart` | Defaults, equality, `copyWith` |
| Use cases | `test/domain/usecase/` | Repository calls and business branches |
| Repository | `test/data/repository/transaction_repository_impl_test.dart` | Delegation and `Result` propagation |
| Migrations | `test/data/database/database_migration_test.dart` | v1 to v2 schema migration with FFI SQLite |
| Main ViewModel | `test/presentation/viewmodel/main_screen_viewmodel_test.dart` | Commands, selected-month totals, navigation, cache reuse, recurring visibility, exclusions, and delayed-load race |
| Active local service | `test/data/services/transaction_local_service_test.dart` | FFI SQLite contract for recurring rows plus requested-month one-time rows |
| Form ViewModel | `test/presentation/viewmodel/transaction_form_viewmodel_test.dart` | Form state and submission |
| UI utilities | `test/presentation/ui/utils/` | Category icons and labels |

## Important gaps

1. Main ViewModel tests mock `GetTransactionsByMonthYearUseCase`; they do not prove the active SQLite query returns the expected rows.
2. There is no dedicated test for `getNonRecurringBalance()` through the active local service.
3. There is no `MainScreen` or `MainTopBar` widget test that verifies the production binding.
4. Existing tests use `DateTime.now()` in several cases, so month-boundary execution can make them time-sensitive.

## Required tests for the monthly bar task

New test names and test code must be in English.

- Verify selected-month totals exclude rows from another month.
- Verify navigation changes totals and the selected list.
- Verify A → B → A reuses each month query once and restores A totals.
- Verify recurring start/end rules and per-month exclusions.
- Verify a stale async result cannot overwrite the final selected month.
- Add an FFI SQLite service test for the active monthly query. **Covered.**
- Add a widget test only if the ViewModel tests cannot prove the `MainScreen` binding.

## Required commands

```bash
dart format lib test
flutter test
flutter analyze
```

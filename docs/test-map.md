# Test map

## Existing coverage

| Area | Test location | Coverage |
|---|---|---|
| Models | `test/domain/model/transaction_test.dart` | Defaults, equality, `copyWith` |
| Use cases | `test/domain/usecase/` | Repository calls and business branches |
| Repository | `test/data/repository/transaction_repository_impl_test.dart` | Delegation and `Result` propagation |
| Migrations | `test/data/database/database_migration_test.dart` | v1 to v2 schema migration, and v1 and v2 to v3 through `validateAndMigrateIfNeeded` with row preservation |
| Main ViewModel | `test/presentation/viewmodel/main_screen_viewmodel_test.dart` | Commands, selected-month totals, navigation, cache reuse, recurring visibility, exclusions, and delayed-load race |
| Active local service | `test/data/services/transaction_local_service_test.dart` | FFI SQLite contract for recurring rows plus requested-month one-time rows |
| Form ViewModel | `test/presentation/viewmodel/transaction_form_viewmodel_test.dart` | Form state and submission |
| UI utilities | `test/presentation/ui/utils/` | Category icons and labels |
| Category model | `test/domain/model/custom_category_test.dart` | Slug building, accents, built-in collision, mapper round trip |
| Category data | `test/data/services/category_local_service_test.dart`, `test/data/repository/category_repository_impl_test.dart` | FFI SQLite contract of the `categories` table and repository delegation |
| Category rules | `test/domain/usecase/create_custom_category_usecase_test.dart`, `test/domain/usecase/delete_custom_category_usecase_test.dart` | Name validation, duplicates, and the in-use refusal with its count |
| Category UI | `test/presentation/viewmodel/category_viewmodel_test.dart`, `test/presentation/ui/widgets/category_manager_dialog_test.dart`, `test/presentation/ui/widgets/transaction_dialog_test.dart` | Reload after create and delete, the dialog's error messages, and the dropdown entries |
| Edit rules | `test/domain/usecase/update_transaction_usecase_test.dart`, `test/domain/usecase/update_recurring_transaction_usecase_test.dart`, `test/domain/model/month_year_test.dart` | Delegation, the four recurring spans with their collapse cases, and month arithmetic |
| Edit UI | `test/presentation/ui/widgets/transaction_card_test.dart`, `test/presentation/ui/widgets/recurring_scope_dialog_test.dart`, `integration_test/edit_transaction_test.dart` | The tappable card, the disabled scope option, and the four end-to-end edit paths |

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

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.0.0] - 2026-08-27

### Added
- Edit a transaction from the pencil button on its card: the dialog opens pre-filled with the stored type, category, amount, notes and `Repete` switch
- Editing a recurring transaction asks which months the change covers — `Apenas este mês`, `Este mês e anteriores`, `Este mês e futuros`, `Todos os meses` — through the four-option dialog the delete flow already used
- Turning the `Repete` switch off while editing a recurring transaction leaves `Este mês e anteriores` disabled, because a one-off row cannot cover past months
- `UpdateTransactionUseCase` and `UpdateRecurringTransactionUseCase`, with `updateItem` and `updateRecurringItem` on `MainScreenViewModel`
- `MonthYear` domain model carrying the month arithmetic the recurring rules need
- Localization keys `recurringEditTitle` and `transactionEditTooltip` in Portuguese, English and Spanish
- E2E test covering the four edit paths

### Changed
- **Breaking**: `RecurringDeleteMode` is now `RecurringScope` in `lib/domain/model/recurring_scope.dart`, and `RecurringDeleteDialog` is now `RecurringScopeDialog`, taking its heading as a `title` parameter and an optional `disabledScopes` set
- **Breaking**: `TransactionCard` and `TransactionList` require an `onEdit` callback, and `MainScreenViewModel` requires the two update use cases
- `DeleteRecurringTransactionUseCase` uses `MonthYear` instead of its own private month helpers
- `TransactionFormViewModel` holds the transaction being edited and exposes `startEditing`, `isEditing` and `buildEditedTransaction`
- `AGENTS.md` states the no-duplication rule as a `## Reuse` section

## [2.3.0] - 2026-08-27

### Added
- Custom categories: create a category with its own name, icon and color from the `Nova categoria` entry of the transaction dialog
- Delete a custom category from the same dialog; the deletion is refused while any transaction still uses it, and the dialog reports how many
- `categories` table in database version 3, with a v2 to v3 migration that creates the table and touches no existing row
- `CustomCategory` model, `CategoryLocalService`, `CategoryRepositoryImpl`, three category use cases and `CategoryViewModel`
- Localization keys for the category manager in Portuguese, English and Spanish

### Changed
- The transaction category dropdown is now a single slug-based dropdown listing the built-in categories, the user's categories and the `Nova categoria` entry
- `FormUiState` holds one `categorySlug` instead of separate `expenseCategory` and `incomeCategory` fields, and clears it when the transaction type changes
- The transaction list and the expenses-by-category chart resolve a user-created slug to its stored icon, color and name

## [2.2.0] - 2026-08-21

### Added
- Landscape orientation now shows a pie chart of the selected month's expenses by category
- `CategoryTotal` domain model and ViewModel aggregation of expenses grouped by category
- Category chart colors and label resolution for the expense categories
- Chart localization keys
- E2E test covering the orientation-triggered chart

### Changed
- `MonthSelector` extracted from the main top bar, removing the old chart navigation button

## [2.1.2] - 2026-07-29

### Fixed
- Income vs. expense bar now shows a fully red gauge when spending meets or exceeds income, instead of an incorrect split

## [2.1.1] - 2026-03-14

### Fixed
- Month navigation race condition: load requests are now queued when already running, preventing stale data
- Delete transaction no longer triggers an inline reload; instead invalidates cache and requests a safe reload
- Recurring item deletion now invalidates cache before reloading

### Changed
- ViewModel refactored with `_requestLoad()` and `invalidateAndReload()` to safely handle concurrent load operations
- Month navigation (`goToPreviousMonth`, `goToNextMonth`, `goToCurrentMonth`) now notifies listeners immediately and requests load instead of filtering in-place

## [2.1.0] - 2026-03-13

### Added
- Two new expense categories (`Expanse Category`)
- Spanish (es) localization support
- New use cases: `GetNonRecurringBalanceUseCase`, `GetTransactionsByMonthYearUseCase`
- Tests for category icon and category mapper utilities

### Fixed
- Month display and navigation issues

### Changed
- Database layer refactored with improved repository, service, and use case separation
- Backup file naming convention updated
- Strings and texts refactored for better localization support
- Month names moved to localization files for proper i18n

## [2.0.0] - 2026-02-18

### Added
- Android release signing with fixed keystore for consistent updates via Obtainium/sideloading
- GitHub Actions CI/CD configured with keystore injection via GitHub Secrets
- Keystore setup documentation in README

### Changed
- Release builds now use a fixed signing key instead of debug signing
- Build configuration migrated from debug signing to release signing config in `build.gradle.kts`

## [1.3.1] - 2026-02-18

### Fixed
- Savings calculation now correctly handles recurring transaction exclusions on a per-month basis

### Changed
- Recurring delete dialog redesigned with pill-shaped buttons for better UX
- README improved with screenshots, badges, and updated dependency list

## [1.3.0] - 2026-02-18

### Added
- Income/expense proportional bar in the top summary replacing the static divider
- Reactivation of excluded recurring transactions when a matching transaction is created
- `removeExclusion` operation across the full data stack (service, repository, DAO)

### Fixed
- Savings calculation now correctly handles recurring transaction exclusions on a per-month basis

### Changed
- Transaction type selector migrated to Flutter's `RadioGroup<TransactionType>` widget
- ViewModel refactored: decomposed monolithic method into focused helpers for clarity

## [1.2.0] - 2026-02-17

### Fixed
- Recurring transactions bug fixes

### Changed
- Project cleanup and code improvements

## [1.1.0] - 2026-02-12

### Added
- Swipe gesture navigation between months (horizontal drag to change months)

### Fixed
- Color adjustments in the UI

## [1.0.0] - 2026-02-04

### Added
- Transaction management (income and expenses)
- Monthly navigation with totals summary
- Recurring transactions support
- Expense and income categories
- Local persistence with SQLite
- Light/dark theme (system automatic)
- Portuguese localization
- Export functionality

### Architecture
- Clean Architecture with MVVM pattern
- Provider for state management
- Repository pattern with local services

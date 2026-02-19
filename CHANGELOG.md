# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

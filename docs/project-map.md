# Project map

## Application entry point

`lib/main.dart` creates the dependency graph with `Provider`:

```text
TransactionLocalService          CategoryLocalService
        ↓                                ↓
TransactionRepositoryImpl        CategoryRepositoryImpl
        ↓                                ↓
     Use cases                        Use cases
        ↓                                ↓
MainScreenViewModel /              CategoryViewModel
TransactionFormViewModel                 ↓
        ↓                                ↓
                    MainScreen
```

The app starts at `MainScreen` and uses a singleton `DatabaseHelper` for SQLite.

## Layer ownership

| Layer | Authoritative files | Responsibility |
|---|---|---|
| Domain model | `lib/domain/model/` | Immutable transaction and exclusion data |
| Domain use cases | `lib/domain/usecase/` | Business operations and recurring deletion rules |
| Data service | `lib/data/services/transaction_local_service.dart` | SQLite reads and writes |
| Repository | `lib/data/repository/transaction_repository_impl.dart` | Delegates domain operations to services |
| Main state | `lib/presentation/viewmodel/main_screen_viewmodel.dart` | Monthly cache, filtering, totals, navigation |
| Form state | `lib/presentation/viewmodel/transaction_form_viewmodel.dart` | Form validation and transaction creation |
| Category data | `lib/data/services/category_local_service.dart` | SQLite reads and writes of the `categories` table |
| Category rules | `lib/domain/usecase/create_custom_category_usecase.dart`, `lib/domain/usecase/delete_custom_category_usecase.dart` | Name validation and the refusal to delete a category still in use |
| Category state | `lib/presentation/viewmodel/category_viewmodel.dart` | The user-created categories, and creating and deleting them |
| Main UI | `lib/presentation/ui/screens/main_screen.dart` | Binds ViewModels to widgets |
| Top bar | `lib/presentation/ui/widgets/main_top_bar.dart` | Renders month selector, summaries, and ratio bar |
| Category UI | `lib/presentation/ui/widgets/category_manager_dialog.dart` | Creating and deleting the user's categories |

## Important non-authoritative path

`lib/data/local/dao/transaction_dao.dart` is not used by `lib/main.dart` or the active repository path. It contains an older stream-based API and filters by `createdAt`, while the active service filters one-time rows by `targetMonth` and `targetYear`.

Do not use `TransactionDao` to diagnose the current screen until it is either wired into the repository or removed in a separate cleanup task.

## Validation entry points

```bash
flutter test
flutter analyze
flutter build apk --debug
```

The test suite currently validates domain logic, repository delegation, migration SQL, ViewModels, and utility mapping. It does not fully exercise the active `TransactionLocalService` through a real SQLite database or the `MainScreen` widget binding.

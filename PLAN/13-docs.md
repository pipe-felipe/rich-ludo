## BLOCK 13 — Update the documentation and the changelog

**Depends on:** BLOCK 12 committed
**Touches:** `docs/database.md` (MODIFY), `docs/schema.sql` (MODIFY), `docs/project-map.md` (MODIFY), `docs/test-map.md` (MODIFY), `README.md` (MODIFY), `CHANGELOG.md` (MODIFY)

6 files, all documentation. §7 records that `docs/project-map.md` and `docs/database.md` went
stale the moment BLOCK 1 landed; this block is where they catch up. No Dart file changes here.

### Goal
The four `docs/` files, the README feature list and the `## [Unreleased]` section of the
changelog describe database version 3, the `categories` table and the user-created categories.

### Context to read first
1. `docs/database.md` — the whole file; `- **Current version:** 2` at line 7, the `## Tables` section, the `### Migration (v1 → v2 on update)` section, and the `## Data Access` full-path diagram.
2. `docs/schema.sql` — the whole file; `-- Version: 2` at line 4 and the `MIGRATION HISTORY` block at lines 89-92.
3. `docs/project-map.md` — the whole file; the dependency diagram and the `## Layer ownership` table.
4. `docs/test-map.md` — the whole file; the `## Existing coverage` table.
5. `CHANGELOG.md:1-10` — the Keep a Changelog header and the empty `## [Unreleased]` section this block fills.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `docs/database.md`, replace the line `- **Current version:** 2` with:
   ```markdown
   - **Current version:** 3
   ```
2. In `docs/database.md`, immediately after the `### recurring_exclusions` table block — that is, after its last table row and before the `---` that follows it — insert:
   ```markdown

   ### `categories`

   Stores only the categories the user created. The 13 built-in categories stay as the
   `ExpenseCategory` and `IncomeCategory` enums in
   `lib/presentation/viewmodel/transaction_form_viewmodel.dart` and are never rows here.

   | Column          | Type    | Constraint                | Description                                              |
   |-----------------|---------|---------------------------|----------------------------------------------------------|
   | `id`            | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique identifier                                        |
   | `slug`          | TEXT    | NOT NULL                  | Value written to `transactions.category`, always prefixed `custom_` |
   | `name`          | TEXT    | NOT NULL                  | Display name typed by the user, up to 30 characters      |
   | `type`          | TEXT    | NOT NULL                  | `'income'` or `'expense'`                                |
   | `iconCodePoint` | INTEGER | NOT NULL                  | Code point of an entry of `customCategoryIcons`          |
   | `colorValue`    | INTEGER | NOT NULL                  | ARGB value of an entry of `CategoryPiColors.customPalette` |
   | `createdAt`     | INTEGER | NOT NULL DEFAULT 0        | Epoch millis, 0 for a row inserted from the dialog       |
   |                 |         | UNIQUE (`slug`, `type`)   | One name per type; the same name may exist for both types |

   The `custom_` prefix is what keeps a user-created slug out of the built-in namespace: a
   database written before version 3 keeps resolving `'food'` or `'salary'` to its built-in
   category, and no existing row is rewritten.
   ```
3. In `docs/database.md`, immediately after the closing ``` of the `### Migration (v1 → v2 on update)` SQL block and before the `### Backup Import Compatibility` heading, insert:
   ```markdown

   ### Migration (v2 → v3 on update)

   `_migrateToV3` creates one table and nothing else. It never reads, writes or deletes a row
   of `transactions` or `recurring_exclusions`, which is why an update cannot lose data.
   `CREATE TABLE IF NOT EXISTS` is what makes it idempotent.

   ```sql
   -- Added in v3
   CREATE TABLE IF NOT EXISTS categories (
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     slug TEXT NOT NULL,
     name TEXT NOT NULL,
     type TEXT NOT NULL,
     iconCodePoint INTEGER NOT NULL,
     colorValue INTEGER NOT NULL,
     createdAt INTEGER NOT NULL DEFAULT 0,
     UNIQUE (slug, type)
   );
   ```
   ```
4. In `docs/database.md`, immediately after the closing ``` of the `### Full path` diagram block, insert:
   ```markdown

   ### Category path

   ```
   DatabaseHelper (singleton, manages connection)
       ↓
   CategoryLocalService (implements CategoryService)
       ↓
   CategoryRepositoryImpl (implements CategoryRepository)
       ↓
       GetCustomCategoriesUseCase, CreateCustomCategoryUseCase, DeleteCustomCategoryUseCase
       ↓
   CategoryViewModel
   ```

   `DeleteCustomCategoryUseCase` also reads `TransactionRepository.getTransactions()` to count
   the transactions that carry the category. It refuses the deletion while that count is above
   zero, so a stored transaction can never point at a category the user can no longer see.
   ```
5. In `docs/schema.sql`, replace the line `-- Version: 2` with:
   ```sql
   -- Version: 3
   ```
6. In `docs/schema.sql`, immediately after the closing `);` of the `CREATE TABLE recurring_exclusions` statement and before the `-- NOTE ON FOREIGN KEYS IN SQLITE` banner, insert:
   ```sql

   -- ============================================
   -- TABLE: categories
   -- Stores only the categories created by the user.
   -- The 13 built-in categories remain Dart enums
   -- and are never rows of this table.
   --
   -- Example: a category named "Mercado" is stored as
   -- (slug='custom_mercado', name='Mercado', type='expense')
   -- and transactions.category holds 'custom_mercado'.
   -- ============================================
   CREATE TABLE categories (
       id INTEGER PRIMARY KEY AUTOINCREMENT,

       -- Value written to transactions.category, always prefixed 'custom_'
       slug TEXT NOT NULL,

       -- Display name typed by the user (up to 30 characters)
       name TEXT NOT NULL,

       -- Category type: 'income' or 'expense'
       type TEXT NOT NULL,

       -- Code point of an entry of customCategoryIcons
       iconCodePoint INTEGER NOT NULL,

       -- ARGB value of an entry of CategoryPiColors.customPalette
       colorValue INTEGER NOT NULL,

       -- Creation timestamp (milliseconds since epoch)
       createdAt INTEGER NOT NULL DEFAULT 0,

       -- One name per type; the same name may exist for both types
       UNIQUE (slug, type)
   );
   ```
7. In `docs/schema.sql`, replace the line `-- Version 2: Added endMonth, endYear and the recurring_exclusions table` with:
   ```sql
   -- Version 2: Added endMonth, endYear and the recurring_exclusions table
   -- Version 3: Added the categories table for user-created categories
   ```
8. In `docs/project-map.md`, replace the dependency diagram — the fenced `text` block from `TransactionLocalService` to `MainScreen` — with:
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
9. In `docs/project-map.md`, in the `## Layer ownership` table, insert these three rows immediately after the `| Form state | ... |` row:
   ```markdown
   | Category data | `lib/data/services/category_local_service.dart` | SQLite reads and writes of the `categories` table |
   | Category rules | `lib/domain/usecase/create_custom_category_usecase.dart`, `lib/domain/usecase/delete_custom_category_usecase.dart` | Name validation and the refusal to delete a category still in use |
   | Category state | `lib/presentation/viewmodel/category_viewmodel.dart` | The user-created categories, and creating and deleting them |
   ```
10. In `docs/project-map.md`, in the same table, insert this row immediately after the `| Top bar | ... |` row:
    ```markdown
    | Category UI | `lib/presentation/ui/widgets/category_manager_dialog.dart` | Creating and deleting the user's categories |
    ```
11. In `docs/test-map.md`, in the `## Existing coverage` table, insert these four rows immediately after the `| UI utilities | ... |` row:
    ```markdown
    | Category model | `test/domain/model/custom_category_test.dart` | Slug building, accents, built-in collision, mapper round trip |
    | Category data | `test/data/services/category_local_service_test.dart`, `test/data/repository/category_repository_impl_test.dart` | FFI SQLite contract of the `categories` table and repository delegation |
    | Category rules | `test/domain/usecase/create_custom_category_usecase_test.dart`, `test/domain/usecase/delete_custom_category_usecase_test.dart` | Name validation, duplicates, and the in-use refusal with its count |
    | Category UI | `test/presentation/viewmodel/category_viewmodel_test.dart`, `test/presentation/ui/widgets/category_manager_dialog_test.dart`, `test/presentation/ui/widgets/transaction_dialog_test.dart` | Reload after create and delete, the dialog's error messages, and the dropdown entries |
    ```
12. In `docs/test-map.md`, in the `## Existing coverage` table, replace the `| Migrations | ... |` row with:
    ```markdown
    | Migrations | `test/data/database/database_migration_test.dart` | v1 to v2 schema migration, and v1 and v2 to v3 through `validateAndMigrateIfNeeded` with row preservation |
    ```
13. In `README.md`, replace the line `- ✅ Expense and income categories` with:
    ```markdown
    - ✅ Expense and income categories
    - ✅ Custom categories created by the user, with their own name, icon and color
    ```
14. In `CHANGELOG.md`, replace the line `## [Unreleased]` and the blank line after it with:
    ```markdown
    ## [Unreleased]

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

    ```
15. Do not run `dart format` in this block. It touches no Dart file.

### Do not
- Do not create a `## [X.Y.Z] - <date>` section, bump `version:` in `pubspec.yaml`, change the README version badge, or create a git tag. §3 leaves the release to the `generate-version` skill.
- Do not remove or rewrite the `## Important non-authoritative path` section of `docs/project-map.md` about `TransactionDao`; it is still accurate and §3 puts that cleanup out of scope.
- Do not edit `AGENTS.md` or `docs/monthly-data-flow.md`; nothing in this task changed what they describe.
- Do not remove any entry from `docs/known-issues.md`.
- Do not touch a `.dart` file in this block.

### Verify
Run from the repository root, in this order:
```
grep -c 'CREATE TABLE categories' docs/schema.sql
grep -n 'Current version' docs/database.md
flutter analyze
flutter test
```
Expected: the first prints `1` — it prints `0` before this block ran; the second prints `- **Current version:** 3`; `flutter analyze` exits 0 printing `No issues found!`; `flutter test` exits 0 and reports `All tests passed!` with 299 tests, unchanged from BLOCK 12 because this block adds no test.

### If verification fails
1. Read the failing output in full.
2. Fix only the six files listed in **Touches**.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 13's row in §12 Status to `DONE`.
2. Run:
   ```
   git add docs/database.md docs/schema.sql docs/project-map.md docs/test-map.md README.md CHANGELOG.md PLAN.md
   git commit -m "Document the categories table and the user-created categories"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

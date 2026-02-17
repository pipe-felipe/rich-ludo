# Database — RichLudo

## Overview

- **Engine:** SQLite via `sqflite` package
- **File:** `rich_ludo.db`
- **Current version:** 2
- **Config centralized in:** `lib/config/database_config.dart`

---

## Tables

### `transactions`

| Column        | Type    | Constraint                   | Description                                         |
|---------------|---------|------------------------------|------------------------------------------------------|
| `id`          | INTEGER | PRIMARY KEY AUTOINCREMENT    | Unique identifier                                    |
| `amountCents` | INTEGER | NOT NULL                     | Value in cents (e.g. 1050 = R$ 10.50)                |
| `type`        | TEXT    | NOT NULL                     | `'income'` or `'expense'`                            |
| `category`    | TEXT    | nullable                     | Category name (e.g. `'food'`, `'salary'`)            |
| `description` | TEXT    | nullable                     | User notes                                           |
| `humanDate`   | TEXT    | nullable                     | Human-readable date provided by user                 |
| `isRecurring` | INTEGER | NOT NULL DEFAULT 0           | `0` = normal, `1` = recurring                        |
| `createdAt`   | INTEGER | NOT NULL DEFAULT 0           | Epoch millis of the creation month start              |
| `targetMonth` | INTEGER | NOT NULL DEFAULT 0           | Start month (1-12)                                   |
| `targetYear`  | INTEGER | NOT NULL DEFAULT 0           | Start year                                           |
| `endMonth`    | INTEGER | nullable                     | Recurrence end month (1-12), null = infinite          |
| `endYear`     | INTEGER | nullable                     | Recurrence end year, null = infinite                  |

### `recurring_exclusions`

Stores specific months that were removed from a recurring transaction (without deleting the original record).

| Column          | Type    | Constraint                                                       | Description                   |
|-----------------|---------|------------------------------------------------------------------|--------------------------------|
| `id`            | INTEGER | PRIMARY KEY AUTOINCREMENT                                        | Unique identifier              |
| `transactionId` | INTEGER | NOT NULL, FK → `transactions(id)` ON DELETE CASCADE              | Affected recurring transaction |
| `month`         | INTEGER | NOT NULL                                                         | Excluded month (1-12)          |
| `year`          | INTEGER | NOT NULL                                                         | Excluded year                  |

---

## Creation and Migration

### `DatabaseHelper` (`lib/data/local/database/database_helper.dart`)

- **Singleton** via `DatabaseHelper.instance`
- Lazy init: database is opened only on first access via `get database`
- File path resolved from sqflite's `getDatabasesPath()`

### Creation (clean install at v2)

The `onCreate` callback runs only on **first install**, creating both tables at version 2.

### Migration (v1 → v2 on update)

The `onUpgrade` callback runs when the app updates from a previous version.

**Important:** The migration is **idempotent** - it can be executed multiple times safely. Before adding columns or creating tables, it checks if they already exist.

```sql
-- Added in v2
ALTER TABLE transactions ADD COLUMN endMonth INTEGER;
ALTER TABLE transactions ADD COLUMN endYear INTEGER;

CREATE TABLE recurring_exclusions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  transactionId INTEGER NOT NULL,
  month INTEGER NOT NULL,
  year INTEGER NOT NULL,
  FOREIGN KEY (transactionId) REFERENCES transactions (id) ON DELETE CASCADE
);
```

### Backup Import Compatibility

When importing a backup from an older version (v1), the `reopenDatabase()` method automatically calls `validateAndMigrateIfNeeded()` which:

1. Checks the current database version via `PRAGMA user_version`
2. Applies any missing migrations (idempotent)
3. Updates the database version to the current app version

This ensures backups from older app versions work correctly with newer versions.

---

## Data Access

### Full path

```
DatabaseHelper (singleton, manages connection)
    ↓
TransactionLocalService (implements TransactionService)
    ↓
TransactionRepositoryImpl (implements TransactionRepository)
    ↓
UseCases (GetTransactionsUseCase, MakeTransactionUseCase, etc.)
    ↓
ViewModels
```

### `TransactionLocalService` (`lib/data/services/transaction_local_service.dart`)

All operations return `Result<T>` and wrap exceptions with try/catch.

| Method                            | SQL equivalent                                                   |
|-----------------------------------|------------------------------------------------------------------|
| `getAllTransactions()`            | `SELECT * FROM transactions ORDER BY createdAt DESC`             |
| `getTransactionsForMonth(s, e)`  | `WHERE isRecurring = 1 OR (createdAt >= s AND createdAt < e)`    |
| `getTransactionById(id)`         | `WHERE id = ? LIMIT 1`                                          |
| `insertTransaction(tx)`          | `INSERT INTO transactions ...`                                   |
| `insertAll(txs)`                 | Batch `INSERT` inside a `db.transaction`                         |
| `updateTransaction(tx)`          | `UPDATE transactions SET ... WHERE id = ?`                       |
| `deleteTransaction(id)`          | `DELETE FROM transactions WHERE id = ?`                          |
| `deleteAll()`                    | `DELETE FROM recurring_exclusions` + `DELETE FROM transactions`  |
| `getAllExclusions()`             | `SELECT * FROM recurring_exclusions`                             |
| `addExclusion(ex)`               | `INSERT INTO recurring_exclusions ...`                           |
| `deleteExclusionsForTransaction(id)` | `DELETE FROM recurring_exclusions WHERE transactionId = ?`   |

---

## Mappers

### `TransactionMapper` (`lib/domain/model/transaction_mapper.dart`)

- `fromMap(Map)` → `Transaction` — converts `isRecurring` from `int` (0/1) to `bool`
- `toMap(Transaction)` → `Map` — converts `bool` to `int` (0/1)

### `RecurringExclusionMapper` (`lib/domain/model/recurring_exclusion_mapper.dart`)

- `fromMap(Map)` → `RecurringExclusion`
- `toMap(RecurringExclusion)` → `Map`

---

## Recurring Items Data Flow

### Loading

1. `MainScreenViewModel` calls `GetTransactionsUseCase` + `GetExclusionsUseCase`
2. **All** transactions and exclusions are loaded into memory
3. When navigating between months, filtering happens **in memory** (no new query)

### Recurring visibility rule

A recurring transaction appears in month X/Y if **all** conditions are true:

1. `targetMonth/targetYear <= X/Y` (started before or in the current month)
2. `endMonth/endYear` is null **or** `X/Y <= endMonth/endYear` (hasn't ended yet)
3. No `RecurringExclusion` exists with `month = X` and `year = Y`

### Recurring deletion (4 modes)

| Mode                       | Database action                                                      |
|----------------------------|----------------------------------------------------------------------|
| This month only            | `INSERT` into `recurring_exclusions`                                 |
| This month and previous    | `UPDATE targetMonth/targetYear` to the next month                    |
| This month and future      | `UPDATE endMonth/endYear` to the previous month                      |
| All months                 | `DELETE` transaction + exclusions (CASCADE)                          |

---

## Backup / Restore

- **Export:** `ExportLocalService` copies the `.db` file to the documents directory
- **Import:** `ExportLocalService` restores the `.db` file from a `.ludo` file selected by the user

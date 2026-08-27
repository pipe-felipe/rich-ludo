## BLOCK 1 — Add the `categories` table and the v3 migration

**Depends on:** none
**Touches:** `lib/config/database_config.dart` (MODIFY), `lib/data/local/database/database_helper.dart` (MODIFY), `test/data/database/database_migration_test.dart` (MODIFY)

### Goal
A version 1 database and a version 2 database both reach `PRAGMA user_version = 3` with a
`categories` table added and every existing `transactions` and `recurring_exclusions` row
byte-identical to what it was before.

### Context to read first
1. `lib/config/database_config.dart` — the whole file (8 lines); the constants this block extends.
2. `lib/data/local/database/database_helper.dart` — the whole file (130 lines); `_createDB` at line 38, `_upgradeDB` at line 66, `_migrateToV2` at line 72, `validateAndMigrateIfNeeded` at line 107. Note that `validateAndMigrateIfNeeded` reads `PRAGMA user_version`, applies the missing migrations and then writes `PRAGMA user_version = DatabaseConfig.databaseVersion`; it is the method a restored backup goes through.
3. `test/data/database/database_migration_test.dart` — the whole file (192 lines); the FFI setup at lines 6-9, the `group` / `setUp` / `tearDown` shape at lines 11-41, and the `existing v1 data should be preserved after migration` test at line 107 — the assertion style to mirror.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. In `lib/config/database_config.dart`, change line 5 from `static const int databaseVersion = 2;` to:
   ```dart
   static const int databaseVersion = 3;
   ```
2. In the same file, immediately after the line `static const String exclusionsTableName = 'recurring_exclusions';`, insert:
   ```dart
   static const String categoriesTableName = 'categories';
   ```
3. In `lib/data/local/database/database_helper.dart`, immediately after the line `DatabaseHelper.forTesting(Database database) : _injectedDatabase = database;`, insert this constant. It is declared once and used by both `_createDB` and `_migrateToV3`, so the DDL never appears twice:
   ```dart
   /// DDL of the `categories` table introduced in database version 3.
   /// `IF NOT EXISTS` is what makes the v3 migration idempotent.
   static const String _createCategoriesTable =
       '''
       CREATE TABLE IF NOT EXISTS ${DatabaseConfig.categoriesTableName} (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         slug TEXT NOT NULL,
         name TEXT NOT NULL,
         type TEXT NOT NULL,
         iconCodePoint INTEGER NOT NULL,
         colorValue INTEGER NOT NULL,
         createdAt INTEGER NOT NULL DEFAULT 0,
         UNIQUE (slug, type)
       )
       ''';
   ```
4. In `_createDB`, immediately after the closing `''');` of the `CREATE TABLE ${DatabaseConfig.exclusionsTableName}` statement and before the closing brace of the method, insert:
   ```dart
   await db.execute(_createCategoriesTable);
   ```
5. Replace the whole body of `_upgradeDB` with:
   ```dart
   if (oldVersion < 2) {
     await _migrateToV2(db);
   }
   if (oldVersion < 3) {
     await _migrateToV3(db);
   }
   ```
6. Immediately after the closing brace of `_migrateToV2`, insert:
   ```dart
   /// Adds the `categories` table. This migration only creates a table: it never
   /// reads, writes or deletes a row of `${DatabaseConfig.tableName}` or of
   /// `${DatabaseConfig.exclusionsTableName}`, so an existing database keeps
   /// every transaction the user already saved.
   Future<void> _migrateToV3(Database db) async {
     await db.execute(_createCategoriesTable);
   }
   ```
   Write that doc comment with the two `${...}` interpolations exactly as shown: `///` comments are text, and this keeps the table names from being spelled twice.
7. In `validateAndMigrateIfNeeded`, immediately after the closing brace of the existing `if (currentVersion < 2) { await _migrateToV2(db); }` block and before the `await db.execute('PRAGMA user_version = ...')` line, insert:
   ```dart
   if (currentVersion < 3) {
     await _migrateToV3(db);
   }
   ```
8. In `test/data/database/database_migration_test.dart`, add this import after the existing `import 'package:rich_ludo/config/database_config.dart';` line:
   ```dart
   import 'package:rich_ludo/data/local/database/database_helper.dart';
   ```
9. In the same file, immediately after the closing `});` of the existing `group('Database Migration v1 → v2', ...)` and before the final closing `}` of `main()`, insert a second group with exactly these 7 tests. Unlike the v1→v2 group, which re-implements the migration in the local `_migrateV1ToV2` helper, this group drives the production code through `DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded()`:
   ```dart
   group('Database Migration v2 → v3', () {
     late Database db;

     setUp(() async {
       db = await databaseFactoryFfi.openDatabase(
         inMemoryDatabasePath,
         options: OpenDatabaseOptions(
           version: 2,
           onCreate: (db, version) async {
             await db.execute('''
               CREATE TABLE ${DatabaseConfig.tableName} (
                 id INTEGER PRIMARY KEY AUTOINCREMENT,
                 amountCents INTEGER NOT NULL,
                 type TEXT NOT NULL,
                 category TEXT,
                 description TEXT,
                 humanDate TEXT,
                 isRecurring INTEGER NOT NULL DEFAULT 0,
                 createdAt INTEGER NOT NULL DEFAULT 0,
                 targetMonth INTEGER NOT NULL DEFAULT 0,
                 targetYear INTEGER NOT NULL DEFAULT 0,
                 endMonth INTEGER,
                 endYear INTEGER
               )
             ''');
             await db.execute('''
               CREATE TABLE ${DatabaseConfig.exclusionsTableName} (
                 id INTEGER PRIMARY KEY AUTOINCREMENT,
                 transactionId INTEGER NOT NULL,
                 month INTEGER NOT NULL,
                 year INTEGER NOT NULL,
                 FOREIGN KEY (transactionId) REFERENCES ${DatabaseConfig.tableName} (id) ON DELETE CASCADE
               )
             ''');
           },
         ),
       );
     });

     tearDown(() async {
       await db.close();
     });

     test('v2 database should not have the categories table', () async {
       final tables = await db.rawQuery(
         "SELECT name FROM sqlite_master WHERE type='table' AND name='${DatabaseConfig.categoriesTableName}'",
       );

       expect(tables, isEmpty);
     });

     test('v2->v3 migration should create the categories table', () async {
       await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();

       final tables = await db.rawQuery(
         "SELECT name FROM sqlite_master WHERE type='table' AND name='${DatabaseConfig.categoriesTableName}'",
       );

       expect(tables, hasLength(1));
     });

     test('v2->v3 migration should set the database version to 3', () async {
       await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();

       final versionResult = await db.rawQuery('PRAGMA user_version');

       expect(versionResult.first['user_version'], equals(3));
     });

     test('existing v2 data should be preserved after migration', () async {
       final transactionId = await db.insert(DatabaseConfig.tableName, {
         'amountCents': 12345,
         'type': 'expense',
         'category': 'food',
         'description': 'Groceries',
         'humanDate': '2026-08-02',
         'isRecurring': 1,
         'createdAt': DateTime(2026, 8, 1).millisecondsSinceEpoch,
         'targetMonth': 8,
         'targetYear': 2026,
         'endMonth': 12,
         'endYear': 2026,
       });
       await db.insert(DatabaseConfig.exclusionsTableName, {
         'transactionId': transactionId,
         'month': 9,
         'year': 2026,
       });

       await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();

       final transactions = await db.query(DatabaseConfig.tableName);
       final exclusions = await db.query(DatabaseConfig.exclusionsTableName);

       expect(transactions, hasLength(1));
       expect(transactions.first['amountCents'], equals(12345));
       expect(transactions.first['category'], equals('food'));
       expect(transactions.first['description'], equals('Groceries'));
       expect(transactions.first['isRecurring'], equals(1));
       expect(transactions.first['endMonth'], equals(12));
       expect(transactions.first['endYear'], equals(2026));
       expect(exclusions, hasLength(1));
       expect(exclusions.first['transactionId'], equals(transactionId));
       expect(exclusions.first['month'], equals(9));
     });

     test('migration should be idempotent (can execute multiple times)', () async {
       await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();
       await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();

       final tables = await db.rawQuery(
         "SELECT name FROM sqlite_master WHERE type='table' AND name='${DatabaseConfig.categoriesTableName}'",
       );

       expect(tables, hasLength(1));
     });

     test('categories table should reject a duplicate slug for the same type', () async {
       await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();

       const row = {
         'slug': 'custom_mercado',
         'name': 'Mercado',
         'type': 'expense',
         'iconCodePoint': 0xe59c,
         'colorValue': 0xFFC62828,
         'createdAt': 0,
       };
       await db.insert(DatabaseConfig.categoriesTableName, row);

       await expectLater(
         db.insert(DatabaseConfig.categoriesTableName, row),
         throwsA(isA<DatabaseException>()),
       );
     });

     test('categories table should accept the same slug for the other type', () async {
       await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();

       await db.insert(DatabaseConfig.categoriesTableName, {
         'slug': 'custom_bonus',
         'name': 'Bonus',
         'type': 'expense',
         'iconCodePoint': 0xe59c,
         'colorValue': 0xFFC62828,
         'createdAt': 0,
       });
       await db.insert(DatabaseConfig.categoriesTableName, {
         'slug': 'custom_bonus',
         'name': 'Bonus',
         'type': 'income',
         'iconCodePoint': 0xe59c,
         'colorValue': 0xFFC62828,
         'createdAt': 0,
       });

       final rows = await db.query(DatabaseConfig.categoriesTableName);

       expect(rows, hasLength(2));
     });
   });
   ```
10. In the same file, immediately after the closing `});` of the group added in step 9 and before the final closing `}` of `main()`, insert one more group proving the backup-restore path from version 1 lands on version 3:
    ```dart
    group('Database Migration v1 → v3', () {
      late Database db;

      setUp(() async {
        db = await databaseFactoryFfi.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE ${DatabaseConfig.tableName} (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  amountCents INTEGER NOT NULL,
                  type TEXT NOT NULL,
                  category TEXT,
                  description TEXT,
                  humanDate TEXT,
                  isRecurring INTEGER NOT NULL DEFAULT 0,
                  createdAt INTEGER NOT NULL DEFAULT 0,
                  targetMonth INTEGER NOT NULL DEFAULT 0,
                  targetYear INTEGER NOT NULL DEFAULT 0
                )
              ''');
            },
          ),
        );
      });

      tearDown(() async {
        await db.close();
      });

      test('a restored v1 backup should reach v3 with its rows intact', () async {
        await db.insert(DatabaseConfig.tableName, {
          'amountCents': 999,
          'type': 'income',
          'category': 'salary',
          'description': 'Old backup row',
          'humanDate': '01/01/2026',
          'isRecurring': 0,
          'createdAt': DateTime(2026, 1, 1).millisecondsSinceEpoch,
          'targetMonth': 1,
          'targetYear': 2026,
        });

        await DatabaseHelper.forTesting(db).validateAndMigrateIfNeeded();

        final tableInfo = await db.rawQuery(
          'PRAGMA table_info(${DatabaseConfig.tableName})',
        );
        final columnNames = tableInfo.map((col) => col['name'] as String).toSet();
        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('${DatabaseConfig.exclusionsTableName}', '${DatabaseConfig.categoriesTableName}')",
        );
        final versionResult = await db.rawQuery('PRAGMA user_version');
        final transactions = await db.query(DatabaseConfig.tableName);

        expect(columnNames.contains('endMonth'), isTrue);
        expect(columnNames.contains('endYear'), isTrue);
        expect(tables, hasLength(2));
        expect(versionResult.first['user_version'], equals(3));
        expect(transactions, hasLength(1));
        expect(transactions.first['amountCents'], equals(999));
        expect(transactions.first['description'], equals('Old backup row'));
      });
    });
    ```
11. Run the §5 `write-only` formatter on the Touches paths only:
    ```
    dart format lib/config/database_config.dart lib/data/local/database/database_helper.dart test/data/database/database_migration_test.dart
    ```

### Do not
- Do not write an `ALTER TABLE`, `UPDATE`, `DELETE`, or `INSERT` against `transactions` or `recurring_exclusions` in `_migrateToV3`. §3 puts touching existing rows out of scope, and the tests in steps 9 and 10 exist to catch it.
- Do not drop or recreate the `transactions` table to add the `UNIQUE` constraint anywhere; the constraint belongs to the new `categories` table only.
- Do not seed the 13 built-in enum values into the `categories` table. §1 keeps them as enums.
- Do not create `lib/domain/model/custom_category.dart` here — that is BLOCK 2.
- Do not change `_migrateToV2` or any assertion of the existing `group('Database Migration v1 → v2', ...)`.

### Verify
Run from the repository root, in this order:
```
flutter test test/data/database/database_migration_test.dart
flutter analyze
flutter test
```
Expected: the first command exits 0 and reports `+15` passing tests (7 existing + 7 from step 9 + 1 from step 10); `flutter analyze` exits 0 printing `No issues found!`; `flutter test` exits 0 and reports `All tests passed!` with 226 tests, which is the §6 Baseline of 218 plus the 8 new ones.

### If verification fails
1. Read the failing output in full.
2. Fix only `lib/config/database_config.dart`, `lib/data/local/database/database_helper.dart` and `test/data/database/database_migration_test.dart`.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 1's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/config/database_config.dart lib/data/local/database/database_helper.dart test/data/database/database_migration_test.dart PLAN.md
   git commit -m "Add the categories table in database version 3"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

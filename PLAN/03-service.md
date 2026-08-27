## BLOCK 3 — Add `CategoryService` and `CategoryLocalService`

**Depends on:** BLOCK 2 committed
**Touches:** `lib/data/services/category_service.dart` (NEW), `lib/data/services/category_local_service.dart` (NEW), `test/data/services/category_local_service_test.dart` (NEW)

### Goal
`CategoryLocalService` reads, inserts and deletes rows of the `categories` table against a real
FFI SQLite database, returning `Result.ok` on success and `Result.error` when SQLite rejects the
statement.

### Context to read first
1. `lib/data/services/transaction_service.dart` — the whole file (35 lines); the abstract-interface shape to mirror: `abstract class`, one `Future<Result<T>>` method per operation, no constructor.
2. `lib/data/services/transaction_local_service.dart:1-33` and `:103-152` — the implementation shape to mirror: the `DatabaseHelper? databaseHelper` optional constructor parameter defaulting to `DatabaseHelper.instance`, the `Future<Database> get database` getter, and the `try { ... } on Exception catch (e) { return Result.error(e); }` body of every method.
3. `test/data/services/transaction_local_service_test.dart:1-35` — the FFI test harness to mirror: `sqfliteFfiInit()` and `databaseFactory = databaseFactoryFfi` in `setUpAll`, an `inMemoryDatabasePath` database opened in `setUp` with `DatabaseConfig.databaseVersion`, `DatabaseHelper.forTesting(database)` injected into the service, and `tearDown(() => database.close())`.
4. §8 Security invariants — the category name is user input; it must reach SQLite only through `db.insert`'s map and `whereArgs`, never through string interpolation.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Create `lib/data/services/category_service.dart` with exactly this content:
   ```dart
   import 'dart:async';
   import '../../domain/model/custom_category.dart';
   import '../../utils/result.dart';

   abstract class CategoryService {
     Future<Result<List<CustomCategory>>> getAllCategories();

     Future<Result<int>> insertCategory(CustomCategory category);

     Future<Result<int>> deleteCategory(int id);
   }
   ```
2. Create `lib/data/services/category_local_service.dart` with exactly this content:
   ```dart
   import 'dart:async';
   import 'package:sqflite/sqflite.dart';
   import '../../config/database_config.dart';
   import '../../domain/model/custom_category.dart';
   import '../../domain/model/custom_category_mapper.dart';
   import '../../utils/result.dart';
   import '../local/database/database_helper.dart';
   import 'category_service.dart';

   class CategoryLocalService implements CategoryService {
     final DatabaseHelper _databaseHelper;

     CategoryLocalService({DatabaseHelper? databaseHelper})
       : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

     Future<Database> get database => _databaseHelper.database;

     @override
     Future<Result<List<CustomCategory>>> getAllCategories() async {
       try {
         final db = await database;
         final maps = await db.query(
           DatabaseConfig.categoriesTableName,
           orderBy: 'name ASC',
         );
         final categories = maps.map(CustomCategoryMapper.fromMap).toList();
         return Result.ok(categories);
       } on Exception catch (e) {
         return Result.error(e);
       }
     }

     @override
     Future<Result<int>> insertCategory(CustomCategory category) async {
       try {
         final db = await database;
         final id = await db.insert(
           DatabaseConfig.categoriesTableName,
           CustomCategoryMapper.toMap(category),
         );
         return Result.ok(id);
       } on Exception catch (e) {
         return Result.error(e);
       }
     }

     @override
     Future<Result<int>> deleteCategory(int id) async {
       try {
         final db = await database;
         final count = await db.delete(
           DatabaseConfig.categoriesTableName,
           where: 'id = ?',
           whereArgs: [id],
         );
         return Result.ok(count);
       } on Exception catch (e) {
         return Result.error(e);
       }
     }
   }
   ```
   The import of `package:sqflite/sqflite.dart` needs no `hide Transaction`, unlike `transaction_local_service.dart`, because this file never names the `Transaction` model.
3. Create `test/data/services/category_local_service_test.dart` with exactly these 8 tests:
   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:rich_ludo/config/database_config.dart';
   import 'package:rich_ludo/data/local/database/database_helper.dart';
   import 'package:rich_ludo/data/services/category_local_service.dart';
   import 'package:rich_ludo/domain/model/custom_category.dart';
   import 'package:rich_ludo/domain/model/transaction_type.dart';
   import 'package:rich_ludo/utils/result.dart';
   import 'package:sqflite_common_ffi/sqflite_ffi.dart';

   void main() {
     setUpAll(() {
       sqfliteFfiInit();
       databaseFactory = databaseFactoryFfi;
     });

     late Database database;
     late CategoryLocalService service;

     setUp(() async {
       database = await databaseFactoryFfi.openDatabase(
         inMemoryDatabasePath,
         options: OpenDatabaseOptions(
           version: DatabaseConfig.databaseVersion,
           onCreate: (db, version) async {
             await db.execute('''
               CREATE TABLE ${DatabaseConfig.categoriesTableName} (
                 id INTEGER PRIMARY KEY AUTOINCREMENT,
                 slug TEXT NOT NULL,
                 name TEXT NOT NULL,
                 type TEXT NOT NULL,
                 iconCodePoint INTEGER NOT NULL,
                 colorValue INTEGER NOT NULL,
                 createdAt INTEGER NOT NULL DEFAULT 0,
                 UNIQUE (slug, type)
               )
             ''');
           },
         ),
       );
       service = CategoryLocalService(
         databaseHelper: DatabaseHelper.forTesting(database),
       );
     });

     tearDown(() => database.close());

     test('should return an empty list when no category was created', () async {
       final result = await service.getAllCategories();

       expect(result.isOk, isTrue);
       expect(result.asOk.value, isEmpty);
     });

     test('should return the new row id when inserting', () async {
       final result = await service.insertCategory(_expenseDraft('Mercado'));

       expect(result.isOk, isTrue);
       expect(result.asOk.value, equals(1));
     });

     test('should return inserted categories ordered by name', () async {
       await service.insertCategory(_expenseDraft('Mercado'));
       await service.insertCategory(_expenseDraft('Assinaturas'));

       final result = await service.getAllCategories();

       expect(result.isOk, isTrue);
       expect(
         result.asOk.value.map((category) => category.name).toList(),
         equals(['Assinaturas', 'Mercado']),
       );
     });

     test('should round-trip every stored field', () async {
       final draft = _expenseDraft('Mercado');
       await service.insertCategory(draft);

       final result = await service.getAllCategories();
       final stored = result.asOk.value.single;

       expect(stored.slug, equals('custom_mercado'));
       expect(stored.name, equals('Mercado'));
       expect(stored.type, equals(TransactionType.expense));
       expect(stored.iconCodePoint, equals(0xe59c));
       expect(stored.colorValue, equals(0xFFC62828));
     });

     test('should return an error when inserting a duplicate slug of the same type', () async {
       await service.insertCategory(_expenseDraft('Mercado'));

       final result = await service.insertCategory(_expenseDraft('Mercado'));

       expect(result.isError, isTrue);
     });

     test('should accept the same slug for the other transaction type', () async {
       await service.insertCategory(_expenseDraft('Bonus'));

       final result = await service.insertCategory(
         CustomCategory.draft(
           name: 'Bonus',
           type: TransactionType.income,
           iconCodePoint: 0xe553,
           colorValue: 0xFF2E7D32,
         ),
       );

       expect(result.isOk, isTrue);
       expect((await service.getAllCategories()).asOk.value, hasLength(2));
     });

     test('should delete a category by id and return 1', () async {
       final insertResult = await service.insertCategory(_expenseDraft('Mercado'));

       final result = await service.deleteCategory(insertResult.asOk.value);

       expect(result.isOk, isTrue);
       expect(result.asOk.value, equals(1));
       expect((await service.getAllCategories()).asOk.value, isEmpty);
     });

     test('should return 0 when deleting an id that does not exist', () async {
       final result = await service.deleteCategory(404);

       expect(result.isOk, isTrue);
       expect(result.asOk.value, equals(0));
     });
   }

   CustomCategory _expenseDraft(String name) {
     return CustomCategory.draft(
       name: name,
       type: TransactionType.expense,
       iconCodePoint: 0xe59c,
       colorValue: 0xFFC62828,
     );
   }
   ```
4. Run the §5 `write-only` formatter on the Touches paths only:
   ```
   dart format lib/data/services/category_service.dart lib/data/services/category_local_service.dart test/data/services/category_local_service_test.dart
   ```

### Do not
- Do not add a method to `CategoryService` that reads the `transactions` table. §9 assigns the usage count to `DeleteCustomCategoryUseCase`.
- Do not add `updateCategory`, `getCategoryById`, `deleteAll`, or `insertAll` to either file. §3 puts renaming out of scope and nothing else calls them.
- Do not build a SQL string by interpolating a slug, a name or an id (§8). Use `db.insert`'s map and `whereArgs`.
- Do not create `test/fakes/fake_category_service.dart`. Nothing in this plan needs it; §10 gives the repository test a mocktail `Mock` instead.
- Do not touch `lib/data/services/transaction_local_service.dart` or `lib/main.dart` — the dependency wiring is BLOCK 6.

### Verify
Run from the repository root, in this order:
```
flutter test test/data/services/category_local_service_test.dart
flutter analyze
flutter test
```
Expected: the first command exits 0 and reports `+8`; `flutter analyze` exits 0 printing `No issues found!`; `flutter test` exits 0 and reports `All tests passed!` with 246 tests (238 after BLOCK 2, plus 8).

### If verification fails
1. Read the failing output in full.
2. Fix only `lib/data/services/category_service.dart`, `lib/data/services/category_local_service.dart` and `test/data/services/category_local_service_test.dart`.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 3's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/data/services/category_service.dart lib/data/services/category_local_service.dart test/data/services/category_local_service_test.dart PLAN.md
   git commit -m "Add the category local service over the categories table"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

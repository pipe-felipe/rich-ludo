import 'package:flutter_test/flutter_test.dart';
import 'package:rich_ludo/config/database_config.dart';
import 'package:rich_ludo/data/local/database/database_helper.dart';
import 'package:rich_ludo/data/services/category_local_service.dart';
import 'package:rich_ludo/domain/model/custom_category.dart';
import 'package:rich_ludo/domain/model/transaction_type.dart';
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

  test(
    'should return an error when inserting a duplicate slug of the same type',
    () async {
      await service.insertCategory(_expenseDraft('Mercado'));

      final result = await service.insertCategory(_expenseDraft('Mercado'));

      expect(result.isError, isTrue);
    },
  );

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

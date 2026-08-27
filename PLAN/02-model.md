## BLOCK 2 — Add the `CustomCategory` model and its mapper

**Depends on:** BLOCK 1 committed
**Touches:** `lib/domain/model/custom_category.dart` (NEW), `lib/domain/model/custom_category_mapper.dart` (NEW), `test/domain/model/custom_category_test.dart` (NEW)

### Goal
`CustomCategory.draft(name: 'Mercado Municipal', ...)` produces a value whose `slug` is
`'custom_mercado_municipal'`, and `CustomCategoryMapper` round-trips that value through the
column names of the `categories` table.

### Context to read first
1. `lib/domain/model/transaction.dart` — the whole file (101 lines); the immutable-model shape to mirror: `final` fields, a `const` constructor with defaults, `copyWith`, `operator ==` comparing every field, `hashCode` via `Object.hash`.
2. `lib/domain/model/transaction_mapper.dart` — the whole file (41 lines); the mapper shape to mirror: a class with a private `const` constructor, `static fromMap`, `static toMap`, and the `'income'` / `'expense'` string encoding of `TransactionType`. Note `toMap` omits `id`, because the column is `AUTOINCREMENT`.
3. `lib/domain/model/transaction_type.dart` — the whole file (1 line); the enum reused here.
4. `test/domain/model/transaction_test.dart` — the whole file; the model-test style to mirror: `group('Transaction', ...)`, one nested `group` per behaviour, English test names starting with `should`.

Read exactly these. Do not open other files unless a step below names one.

### Steps
1. Create `lib/domain/model/custom_category.dart` with exactly this content:
   ```dart
   import 'transaction_type.dart';

   /// A category the user created, stored as one row of the `categories` table.
   ///
   /// [slug] is what goes into `transactions.category`. It always starts with
   /// [slugPrefix], so it can never equal the `.name` of an `ExpenseCategory` or
   /// an `IncomeCategory` value: a database written before this feature existed
   /// keeps resolving to its built-in category.
   class CustomCategory {
     final int id;
     final String slug;
     final String name;
     final TransactionType type;
     final int iconCodePoint;
     final int colorValue;
     final int createdAt;

     const CustomCategory({
       this.id = 0,
       required this.slug,
       required this.name,
       required this.type,
       required this.iconCodePoint,
       required this.colorValue,
       this.createdAt = 0,
     });

     /// Builds an unsaved category, deriving [slug] from [name].
     /// This is the only place a slug is created.
     factory CustomCategory.draft({
       required String name,
       required TransactionType type,
       required int iconCodePoint,
       required int colorValue,
     }) {
       return CustomCategory(
         slug: slugFor(name),
         name: name.trim(),
         type: type,
         iconCodePoint: iconCodePoint,
         colorValue: colorValue,
       );
     }

     /// Prefix that keeps a user-created slug out of the built-in enum namespace.
     static const String slugPrefix = 'custom_';

     static const Map<String, String> _diacritics = {
       'á': 'a',
       'à': 'a',
       'ã': 'a',
       'â': 'a',
       'ä': 'a',
       'é': 'e',
       'è': 'e',
       'ê': 'e',
       'ë': 'e',
       'í': 'i',
       'ì': 'i',
       'î': 'i',
       'ï': 'i',
       'ó': 'o',
       'ò': 'o',
       'õ': 'o',
       'ô': 'o',
       'ö': 'o',
       'ú': 'u',
       'ù': 'u',
       'û': 'u',
       'ü': 'u',
       'ç': 'c',
       'ñ': 'n',
     };

     /// Lowercases [name], strips its accents and replaces every run of other
     /// characters with a single underscore, then prefixes [slugPrefix].
     /// A name with no letter or digit produces [slugPrefix] alone, which
     /// `CreateCustomCategoryUseCase` rejects.
     static String slugFor(String name) {
       var normalized = name.trim().toLowerCase();

       _diacritics.forEach((accented, plain) {
         normalized = normalized.replaceAll(accented, plain);
       });

       normalized = normalized
           .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
           .replaceAll(RegExp(r'^_+|_+$'), '');

       return '$slugPrefix$normalized';
     }

     CustomCategory copyWith({
       int? id,
       String? slug,
       String? name,
       TransactionType? type,
       int? iconCodePoint,
       int? colorValue,
       int? createdAt,
     }) {
       return CustomCategory(
         id: id ?? this.id,
         slug: slug ?? this.slug,
         name: name ?? this.name,
         type: type ?? this.type,
         iconCodePoint: iconCodePoint ?? this.iconCodePoint,
         colorValue: colorValue ?? this.colorValue,
         createdAt: createdAt ?? this.createdAt,
       );
     }

     @override
     bool operator ==(Object other) {
       if (identical(this, other)) return true;
       return other is CustomCategory &&
           other.id == id &&
           other.slug == slug &&
           other.name == name &&
           other.type == type &&
           other.iconCodePoint == iconCodePoint &&
           other.colorValue == colorValue &&
           other.createdAt == createdAt;
     }

     @override
     int get hashCode {
       return Object.hash(
         id,
         slug,
         name,
         type,
         iconCodePoint,
         colorValue,
         createdAt,
       );
     }
   }
   ```
2. Create `lib/domain/model/custom_category_mapper.dart` with exactly this content:
   ```dart
   import 'custom_category.dart';
   import 'transaction_type.dart';

   class CustomCategoryMapper {
     const CustomCategoryMapper._();

     static CustomCategory fromMap(Map<String, dynamic> map) {
       return CustomCategory(
         id: map['id'] as int,
         slug: map['slug'] as String,
         name: map['name'] as String,
         type: map['type'] == 'income'
             ? TransactionType.income
             : TransactionType.expense,
         iconCodePoint: map['iconCodePoint'] as int,
         colorValue: map['colorValue'] as int,
         createdAt: map['createdAt'] as int,
       );
     }

     static Map<String, dynamic> toMap(CustomCategory category) {
       return {
         'slug': category.slug,
         'name': category.name,
         'type': category.type == TransactionType.income ? 'income' : 'expense',
         'iconCodePoint': category.iconCodePoint,
         'colorValue': category.colorValue,
         'createdAt': category.createdAt,
       };
     }
   }
   ```
3. Create `test/domain/model/custom_category_test.dart` with exactly these 12 tests, following the style of `test/domain/model/transaction_test.dart`:
   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:rich_ludo/domain/model/custom_category.dart';
   import 'package:rich_ludo/domain/model/custom_category_mapper.dart';
   import 'package:rich_ludo/domain/model/transaction_type.dart';
   import 'package:rich_ludo/presentation/viewmodel/transaction_form_viewmodel.dart';

   void main() {
     group('CustomCategory.slugFor', () {
       test('should lowercase and prefix a simple name', () {
         expect(CustomCategory.slugFor('Mercado'), equals('custom_mercado'));
       });

       test('should replace every run of spaces with one underscore', () {
         expect(
           CustomCategory.slugFor('Mercado   Municipal'),
           equals('custom_mercado_municipal'),
         );
       });

       test('should strip Portuguese accents', () {
         expect(
           CustomCategory.slugFor('Alimentação e Saúde'),
           equals('custom_alimentacao_e_saude'),
         );
       });

       test('should trim leading and trailing separators', () {
         expect(CustomCategory.slugFor('  -Casa-  '), equals('custom_casa'));
       });

       test('should return the bare prefix for a name with no letter or digit', () {
         expect(CustomCategory.slugFor('   '), equals(CustomCategory.slugPrefix));
       });

       test('should never collide with a built-in expense category name', () {
         for (final category in ExpenseCategory.values) {
           expect(
             CustomCategory.slugFor(category.name),
             isNot(equals(category.name)),
           );
         }
       });

       test('should never collide with a built-in income category name', () {
         for (final category in IncomeCategory.values) {
           expect(
             CustomCategory.slugFor(category.name),
             isNot(equals(category.name)),
           );
         }
       });
     });

     group('CustomCategory.draft', () {
       test('should derive the slug and trim the name', () {
         final draft = CustomCategory.draft(
           name: '  Mercado  ',
           type: TransactionType.expense,
           iconCodePoint: 0xe59c,
           colorValue: 0xFFC62828,
         );

         expect(draft.slug, equals('custom_mercado'));
         expect(draft.name, equals('Mercado'));
         expect(draft.id, equals(0));
         expect(draft.createdAt, equals(0));
       });
     });

     group('CustomCategory', () {
       const category = CustomCategory(
         id: 7,
         slug: 'custom_mercado',
         name: 'Mercado',
         type: TransactionType.expense,
         iconCodePoint: 0xe59c,
         colorValue: 0xFFC62828,
         createdAt: 1756166400000,
       );

       test('copyWith should change only the given field', () {
         final renamed = category.copyWith(name: 'Feira');

         expect(renamed.name, equals('Feira'));
         expect(renamed.slug, equals('custom_mercado'));
         expect(renamed.id, equals(7));
       });

       test('equality should hold for equal values', () {
         expect(category.copyWith(), equals(category));
         expect(category.copyWith().hashCode, equals(category.hashCode));
       });

       test('equality should fail for a different colorValue', () {
         expect(category.copyWith(colorValue: 0xFF2E7D32), isNot(equals(category)));
       });
     });

     group('CustomCategoryMapper', () {
       test('toMap should encode the type and omit the id', () {
         const category = CustomCategory(
           id: 7,
           slug: 'custom_bonus',
           name: 'Bonus',
           type: TransactionType.income,
           iconCodePoint: 0xe553,
           colorValue: 0xFF2E7D32,
           createdAt: 1756166400000,
         );

         final map = CustomCategoryMapper.toMap(category);

         expect(map['type'], equals('income'));
         expect(map['slug'], equals('custom_bonus'));
         expect(map.containsKey('id'), isFalse);
       });

       test('fromMap should decode a row of the categories table', () {
         final category = CustomCategoryMapper.fromMap({
           'id': 7,
           'slug': 'custom_mercado',
           'name': 'Mercado',
           'type': 'expense',
           'iconCodePoint': 0xe59c,
           'colorValue': 0xFFC62828,
           'createdAt': 1756166400000,
         });

         expect(category.id, equals(7));
         expect(category.type, equals(TransactionType.expense));
         expect(category.iconCodePoint, equals(0xe59c));
         expect(category.colorValue, equals(0xFFC62828));
       });
     });
   }
   ```
4. Run the §5 `write-only` formatter on the Touches paths only:
   ```
   dart format lib/domain/model/custom_category.dart lib/domain/model/custom_category_mapper.dart test/domain/model/custom_category_test.dart
   ```

### Do not
- Do not add a `fromJson`, `toJson`, `toString`, or `compareTo` to `CustomCategory`. Nothing in this plan calls them.
- Do not import `package:flutter/material.dart` into either new file. These are domain files, and §7 rule 1 keeps framework types out of `lib/domain/model/`.
- Do not put the icon list or the color palette here — they are presentation values and belong to BLOCK 8.
- Do not move `ExpenseCategory` or `IncomeCategory` out of `lib/presentation/viewmodel/transaction_form_viewmodel.dart`. The test imports them from there on purpose; moving them is not in §1.
- Do not create the service, the repository, or any use case here — those are BLOCK 3, BLOCK 4 and BLOCK 5.

### Verify
Run from the repository root, in this order:
```
flutter test test/domain/model/custom_category_test.dart
flutter analyze
flutter test
```
Expected: the first command exits 0 and reports `+12`; `flutter analyze` exits 0 printing `No issues found!`; `flutter test` exits 0 and reports `All tests passed!` with 238 tests (226 after BLOCK 1, plus 12).

### If verification fails
1. Read the failing output in full.
2. Fix only `lib/domain/model/custom_category.dart`, `lib/domain/model/custom_category_mapper.dart` and `test/domain/model/custom_category_test.dart`.
3. Re-run every command in **Verify**.
4. After 2 failed attempts, follow §11 R12: mark this block `BLOCKED` in §12, append the exact failing output under `## Blocked` in `PLAN.md`, commit only `PLAN.md`, and stop.

### Commit
1. Set BLOCK 2's row in §12 Status to `DONE`.
2. Run:
   ```
   git add lib/domain/model/custom_category.dart lib/domain/model/custom_category_mapper.dart test/domain/model/custom_category_test.dart PLAN.md
   git commit -m "Add the CustomCategory model and its mapper"
   ```

### Next
Go to §12 Status, take the first row still marked `TODO`, re-read §11 EXECUTOR CONTRACT,
then start that block. If no row is `TODO`, stop and report to the human.

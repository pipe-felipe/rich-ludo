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

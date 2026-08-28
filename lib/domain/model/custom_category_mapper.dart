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

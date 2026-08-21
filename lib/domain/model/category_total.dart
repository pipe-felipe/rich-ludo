/// One slice of the expenses-by-category chart.
///
/// [category] holds the `.name` of an `ExpenseCategory`, or `null` for
/// transactions saved without a category.
class CategoryTotal {
  final String? category;
  final int amountCents;

  const CategoryTotal({required this.category, required this.amountCents});

  CategoryTotal copyWith({String? Function()? category, int? amountCents}) {
    return CategoryTotal(
      category: category != null ? category() : this.category,
      amountCents: amountCents ?? this.amountCents,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryTotal &&
        other.category == category &&
        other.amountCents == amountCents;
  }

  @override
  int get hashCode => Object.hash(category, amountCents);
}

import 'package:flutter/material.dart';

import '../../../domain/model/custom_category.dart';
import '../../../domain/model/transaction.dart';
import 'transaction_card.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> items;
  final List<CustomCategory> customCategories;
  final void Function(Transaction) onDelete;

  const TransactionList({
    super.key,
    required this.items,
    this.customCategories = const [],
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 88),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return TransactionCard(
          item: item,
          customCategories: customCategories,
          onDelete: () => onDelete(item),
        );
      },
    );
  }
}

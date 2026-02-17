import 'package:flutter/material.dart';

import '../../../domain/model/transaction.dart';
import 'transaction_card.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> items;
  final void Function(Transaction) onDelete;

  const TransactionList({
    super.key,
    required this.items,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: 88,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return TransactionCard(
          item: item,
          onDelete: () => onDelete(item),
        );
      },
    );
  }
}

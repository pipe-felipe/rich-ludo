String formatMoney(int amountCents) {
  final negative = amountCents < 0;
  final absCents = amountCents.abs();
  final whole = absCents ~/ 100;
  final fraction = (absCents % 100).toString().padLeft(2, '0');
  final sign = negative ? '-' : '';
  return '$sign$whole.$fraction';
}

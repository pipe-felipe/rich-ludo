import 'package:flutter/material.dart';

IconData getCategoryIcon(String? category, {required bool isIncome}) {
  if (category == null) {
    return isIncome ? Icons.attach_money : Icons.money_off;
  }

  return switch (category) {
    'transport' => Icons.directions_car,
    'gift' => Icons.card_giftcard,
    'recurring' => Icons.repeat,
    'food' => Icons.restaurant,
    'stuff' => Icons.shopping_bag,
    'medicine' => Icons.medical_services,
    'clothes' => Icons.checkroom,

    'salary' => Icons.payments,
    'investment' => Icons.trending_up,
    'other' => Icons.attach_money,
    _ => isIncome ? Icons.attach_money : Icons.money_off,
  };
}

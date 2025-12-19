import 'package:flutter/material.dart';

class CategoryExpense {
  final String categoryId;
  final String categoryName;
  final Color categoryColor;
  final double amount;
  final double percentage;

  CategoryExpense({
    required this.categoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.amount,
    required this.percentage,
  });
}

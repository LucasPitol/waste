import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';
import 'package:meudin_ai_app/models/category_expense.dart';
import 'package:meudin_ai_app/models/spending_category.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/ui/styles.dart';

class ExpenseCategoryVisual {
  final IconData icon;
  final Color color;

  const ExpenseCategoryVisual({
    required this.icon,
    required this.color,
  });
}

/// Single source of truth for category colors (pie chart palette) and icons
/// used in Insights and the full transactions list.
class ExpenseCategoryVisuals {
  static const Color othersColor = Color(0xFFD1D5DB);
  static const Color revenueColor = Colors.green;

  static List<Color> generateSoftPalette(int count) {
    const palette = [
      Color(0xff2DD4BF),
      Styles.primaryColor,
      Color(0xff6366F1),
      Color(0xffF472B6),
    ];

    return palette.take(count).toList();
  }

  static Color chartColorForIndex({
    required int index,
    required String categoryId,
    required int chartCategoryCount,
  }) {
    if (categoryId == 'others') return othersColor;

    final palette = generateSoftPalette(chartCategoryCount);
    return palette[index % palette.length];
  }

  static SpendingCategory othersCategory() {
    return SpendingCategory(
      id: 'others',
      name: 'Outros',
      value: 'others',
      type: 'personal',
      creationDate: DateTime.now(),
      lastUpdate: DateTime.now(),
    );
  }

  static SpendingCategory findCategory(
    String? categoryId,
    List<SpendingCategory> categories,
  ) {
    if (categoryId == null) return othersCategory();

    return categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => SpendingCategory(
        id: categoryId,
        name: 'Outro',
        value: 'other',
        type: 'personal',
        creationDate: DateTime.now(),
        lastUpdate: DateTime.now(),
      ),
    );
  }

  static ExpenseCategoryVisual revenueVisual() {
    return const ExpenseCategoryVisual(
      icon: AppIcons.arrowTrendUp,
      color: revenueColor,
    );
  }

  static ExpenseCategoryVisual resolve({
    required String? categoryId,
    required List<CategoryExpense> chartCategories,
    required List<SpendingCategory> categories,
  }) {
    if (categoryId == null) {
      final others = othersCategory();
      return ExpenseCategoryVisual(
        icon: others.iconData,
        color: othersColor,
      );
    }

    final category = findCategory(categoryId, categories);
    final chartIndex = chartCategories.indexWhere(
      (entry) => entry.categoryId == categoryId,
    );

    final color = chartIndex >= 0
        ? chartColorForIndex(
            index: chartIndex,
            categoryId: categoryId,
            chartCategoryCount: chartCategories.length,
          )
        : category.colorData;

    return ExpenseCategoryVisual(
      icon: category.iconData,
      color: color,
    );
  }

  /// Same aggregation used by the Insights/Home pie chart card.
  static List<CategoryExpense> calculateChartCategories({
    required List<Transaction> transactions,
    required List<SpendingCategory> categories,
  }) {
    final expenses = transactions
        .where((t) => t.amount != null && t.amount! < 0 && t.categoryId != null)
        .toList();

    if (expenses.isEmpty) return [];

    final totalByCategory = <String, double>{};

    for (final transaction in expenses) {
      final categoryId = transaction.categoryId!;
      final amount = transaction.amount!.abs();
      totalByCategory[categoryId] = (totalByCategory[categoryId] ?? 0.0) + amount;
    }

    final totalAmount =
        totalByCategory.values.fold(0.0, (sum, value) => sum + value);
    if (totalAmount == 0) return [];

    var chartCategories = totalByCategory.entries.map((entry) {
      final categoryId = entry.key;
      final amount = entry.value;
      final percentage = (amount / totalAmount) * 100;
      final category = findCategory(categoryId, categories);

      return CategoryExpense(
        categoryId: categoryId,
        categoryName: category.name,
        categoryColor: category.colorData,
        amount: amount,
        percentage: percentage,
      );
    }).toList();

    chartCategories.sort((a, b) => b.amount.compareTo(a.amount));

    if (chartCategories.length > 4) {
      final topCategories = chartCategories.take(4).toList();
      final others = chartCategories.skip(4);
      final othersTotal = others.fold(0.0, (sum, cat) => sum + cat.amount);
      final othersPercentage = (othersTotal / totalAmount) * 100;

      if (othersTotal > 0) {
        topCategories.add(CategoryExpense(
          categoryId: 'others',
          categoryName: 'Outros',
          categoryColor: othersColor,
          amount: othersTotal,
          percentage: othersPercentage,
        ));
      }

      chartCategories = topCategories;
    }

    if (chartCategories.isNotEmpty) {
      final totalPercentage =
          chartCategories.fold(0.0, (sum, entry) => sum + entry.percentage);
      final difference = 100.0 - totalPercentage;
      if (difference.abs() > 0.001) {
        final lastIndex = chartCategories.length - 1;
        final last = chartCategories[lastIndex];
        chartCategories[lastIndex] = CategoryExpense(
          categoryId: last.categoryId,
          categoryName: last.categoryName,
          categoryColor: last.categoryColor,
          amount: last.amount,
          percentage: last.percentage + difference,
        );
      }
    }

    return chartCategories;
  }
}

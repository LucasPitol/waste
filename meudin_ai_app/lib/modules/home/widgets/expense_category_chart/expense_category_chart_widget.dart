import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:meudin_ai_app/models/category_expense.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/models/spending_category.dart';
import 'package:meudin_ai_app/modules/home/widgets/expense_category_chart/expense_category_detail_bottom_sheet.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/utils/expense_category_visuals.dart';
import 'package:intl/intl.dart';
import 'package:meudin_ai_app/utils/constants.dart';
import 'package:meudin_ai_app/modules/home/widgets/expense_category_chart/expense_category_chart_skeleton.dart';
import 'package:get/get.dart';

class ExpenseCategoryChartWidget extends StatelessWidget {
  final List<CategoryExpense> categoryExpenses;
  final DateTime startDate;
  final bool loading;
  final List<Transaction> transactions;
  final List<SpendingCategory> categories;
  final bool showDate;

  const ExpenseCategoryChartWidget({
    super.key,
    required this.categoryExpenses,
    required this.startDate,
    this.loading = false,
    required this.transactions,
    required this.categories,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show skeleton when loading
    if (loading) {
      return const ExpenseCategoryChartSkeleton();
    }

    // Don't show if no expenses
    if (categoryExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        // Abre bottom sheet de detalhamento
        Get.bottomSheet(
          ExpenseCategoryDetailBottomSheet(
            transactions: transactions,
            categories: categories,
            startDate: startDate,
            chartCategoryExpenses: categoryExpenses,
            showDate: showDate,
          ),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark 
              ? theme.colorScheme.surface 
              : Styles.whiteColor,
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark 
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.shade200.withOpacity(0.5), // Sombra mais sutil
              offset: const Offset(0, 1),
              blurRadius: 1,
            ),
          ],
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gastos por categoria',
                style: TextStyle(
                  fontSize: 14.0, // Reduzido de 16 para ser mais discreto
                  fontWeight: FontWeight.w500, // Reduzido de w600
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) 
                      ?? Colors.grey.shade700, // Mais discreto
                ),
              ),
              if (showDate)
                Text(
                  DateFormat.yMMMM(Constants.ptLanguageCode).format(startDate),
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: PieChart(
                      PieChartData(
                        sections: categoryExpenses.asMap().entries.map((entry) {
                          final index = entry.key;
                          final expense = entry.value;
                          final color = ExpenseCategoryVisuals.chartColorForIndex(
                            index: index,
                            categoryId: expense.categoryId,
                            chartCategoryCount: categoryExpenses.length,
                          );

                          return PieChartSectionData(
                            value: expense.amount,
                            title: '',
                            color: color,
                            radius: 7,
                            showTitle: false,
                          );
                        }).toList(),
                        centerSpaceRadius: 36,
                        sectionsSpace: 0,
                        startDegreeOffset: -90,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryExpenses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final expense = entry.value;
                      final color = ExpenseCategoryVisuals.chartColorForIndex(
                        index: index,
                        categoryId: expense.categoryId,
                        chartCategoryCount: categoryExpenses.length,
                      );
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8), // Espaçamento reduzido
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                expense.categoryName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2, // Line-height ajustado
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8) 
                                      ?? Colors.grey.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${expense.percentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                height: 1.2, // Line-height consistente
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4) 
                                    ?? Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}


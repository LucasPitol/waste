import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:meudin_ai_app/models/category_expense.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:intl/intl.dart';
import 'package:meudin_ai_app/utils/constants.dart';
import 'package:meudin_ai_app/modules/home/widgets/expense_category_chart/expense_category_chart_skeleton.dart';

class ExpenseCategoryChartWidget extends StatelessWidget {
  final List<CategoryExpense> categoryExpenses;
  final DateTime startDate;
  final bool loading;

  const ExpenseCategoryChartWidget({
    super.key,
    required this.categoryExpenses,
    required this.startDate,
    this.loading = false,
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? theme.colorScheme.surface 
            : Styles.whiteColor,
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.3)
                : Styles.greyLighter,
            offset: const Offset(0, 2),
            blurRadius: 2,
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
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                ),
              ),
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
          const SizedBox(height: 24),
          // Chart and Legend
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Donut Chart
              SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    sections: categoryExpenses.map((expense) {
                      return PieChartSectionData(
                        value: expense.amount,
                        title: '',
                        color: expense.categoryColor,
                        radius: 50,
                      );
                    }).toList(),
                    centerSpaceRadius: 35, // Cria o buraco do donut
                    sectionsSpace: 2, // Espaço entre segmentos
                    startDegreeOffset: -90, // Começa no topo
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryExpenses.map((expense) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: expense.categoryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              expense.categoryName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                              ),
                            ),
                          ),
                          Text(
                            '${expense.percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
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
    );
  }
}


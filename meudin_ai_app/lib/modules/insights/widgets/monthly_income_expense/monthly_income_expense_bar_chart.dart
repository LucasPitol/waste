import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/modules/insights/widgets/monthly_income_expense/monthly_income_expense_bar_chart_skeleton.dart';
import 'package:meudin_ai_app/modules/insights/widgets/monthly_income_expense/monthly_income_expense_chart_data.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:meudin_ai_app/utils/utils.dart';

class MonthlyIncomeExpenseBarChart extends StatelessWidget {
  static const Color revenueColor = Colors.green;
  static const Color expenseColor = Colors.red;

  final List<Transaction> transactions;
  final DateTime startDate;
  final DateTime endDate;
  final bool loading;

  const MonthlyIncomeExpenseBarChart({
    super.key,
    required this.transactions,
    required this.startDate,
    required this.endDate,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const MonthlyIncomeExpenseBarChartSkeleton();
    }

    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final buckets = MonthlyIncomeExpenseChartData.groupByMonth(
      transactions: transactions,
      startDate: startDate,
      endDate: endDate,
    );

    if (buckets.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final showYear = startDate.year != endDate.year;
    final needsScroll =
        buckets.length > MonthlyIncomeExpenseChartData.scrollThresholdMonths;
    final maxY = MonthlyIncomeExpenseChartData.calculateMaxY(buckets);
    final axisLabelColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.5) ??
        Colors.grey.shade500;

    final chart = BarChart(
      _buildChartData(
        buckets: buckets,
        maxY: maxY,
        showYear: showYear,
        axisLabelColor: axisLabelColor,
        theme: theme,
      ),
      duration: const Duration(milliseconds: 250),
    );

    return Container(
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
                : Colors.grey.shade200.withOpacity(0.5),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Receitas x Despesas por mês',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                  Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          _ChartLegend(theme: theme),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: needsScroll
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: buckets.length *
                          MonthlyIncomeExpenseChartData.scrollGroupWidth,
                      child: chart,
                    ),
                  )
                : chart,
          ),
        ],
      ),
    );
  }

  BarChartData _buildChartData({
    required List<MonthlyIncomeExpenseBucket> buckets,
    required double maxY,
    required bool showYear,
    required Color axisLabelColor,
    required ThemeData theme,
  }) {
    return BarChartData(
      maxY: maxY,
      minY: 0,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (value) => FlLine(
          color: theme.brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade200,
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: maxY / 4,
            getTitlesWidget: (value, meta) {
              if (value < 0 || value > maxY) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  MonthlyIncomeExpenseChartData.formatCompactAxisValue(value),
                  style: TextStyle(
                    fontSize: 10,
                    color: axisLabelColor,
                  ),
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= buckets.length) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  MonthlyIncomeExpenseChartData.formatMonthLabel(
                    buckets[index].month,
                    showYear: showYear,
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: axisLabelColor,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      barGroups: buckets.asMap().entries.map((entry) {
        final index = entry.key;
        final bucket = entry.value;

        return BarChartGroupData(
          x: index,
          barsSpace: 4,
          barRods: [
            BarChartRodData(
              toY: bucket.revenue,
              color: revenueColor,
              width: 10,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
            ),
            BarChartRodData(
              toY: bucket.expense,
              color: expenseColor,
              width: 10,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
            ),
          ],
        );
      }).toList(),
      groupsSpace: needsHorizontalSpacing(buckets.length) ? 16 : 12,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipRoundedRadius: 8,
          getTooltipColor: (_) => theme.brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.grey.shade900,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            if (groupIndex < 0 || groupIndex >= buckets.length) return null;

            final bucket = buckets[groupIndex];
            final isRevenue = rodIndex == 0;
            final value = isRevenue ? bucket.revenue : bucket.expense;
            final label = MonthlyIncomeExpenseChartData.formatMonthLabel(
              bucket.month,
              showYear: showYear,
            );

            return BarTooltipItem(
              '$label\n${isRevenue ? 'Receita' : 'Despesa'}: ${Utils.getAmountFormated(value)}',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 12,
                height: 1.4,
              ),
            );
          },
        ),
      ),
    );
  }

  bool needsHorizontalSpacing(int bucketCount) {
    return bucketCount <= MonthlyIncomeExpenseChartData.scrollThresholdMonths;
  }
}

class _ChartLegend extends StatelessWidget {
  final ThemeData theme;

  const _ChartLegend({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LegendItem(
          color: MonthlyIncomeExpenseBarChart.revenueColor,
          label: 'Receita',
          theme: theme,
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: MonthlyIncomeExpenseBarChart.expenseColor,
          label: 'Despesa',
          theme: theme,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final ThemeData theme;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8) ??
                Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

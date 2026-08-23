import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/modules/insights/widgets/monthly_income_expense/monthly_income_expense_bar_chart_skeleton.dart';
import 'package:meudin_ai_app/modules/insights/widgets/monthly_income_expense/monthly_income_expense_chart_data.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:meudin_ai_app/utils/utils.dart';

class MonthlyIncomeExpenseBarChart extends StatefulWidget {
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
  State<MonthlyIncomeExpenseBarChart> createState() =>
      _MonthlyIncomeExpenseBarChartState();
}

class _MonthlyIncomeExpenseBarChartState
    extends State<MonthlyIncomeExpenseBarChart> {
  MonthlyIncomeExpenseChartMode _mode =
      MonthlyIncomeExpenseChartMode.comparative;

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const MonthlyIncomeExpenseBarChartSkeleton();
    }

    if (widget.transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final buckets = MonthlyIncomeExpenseChartData.groupByMonth(
      transactions: widget.transactions,
      startDate: widget.startDate,
      endDate: widget.endDate,
    );

    if (buckets.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final showYear = widget.startDate.year != widget.endDate.year;
    final needsScroll =
        buckets.length > MonthlyIncomeExpenseChartData.scrollThresholdMonths;
    final axisLabelColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.5) ??
        Colors.grey.shade500;

    final chartData = _mode == MonthlyIncomeExpenseChartMode.comparative
        ? _buildComparativeChartData(
            buckets: buckets,
            maxY: MonthlyIncomeExpenseChartData.calculateMaxY(buckets),
            showYear: showYear,
            axisLabelColor: axisLabelColor,
            theme: theme,
            needsScroll: needsScroll,
          )
        : _buildBalanceChartData(
            buckets: buckets,
            axisRange:
                MonthlyIncomeExpenseChartData.calculateBalanceAxisRange(buckets),
            showYear: showYear,
            axisLabelColor: axisLabelColor,
            theme: theme,
            needsScroll: needsScroll,
          );

    final chart = BarChart(
      chartData,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Receitas x Despesas por mês',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                        Colors.grey.shade700,
                  ),
                ),
              ),
              _ChartModeToggle(
                mode: _mode,
                onChanged: (mode) => setState(() => _mode = mode),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ChartLegend(mode: _mode, theme: theme),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: SizedBox(
              key: ValueKey(_mode),
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
          ),
        ],
      ),
    );
  }

  BarChartData _buildComparativeChartData({
    required List<MonthlyIncomeExpenseBucket> buckets,
    required double maxY,
    required bool showYear,
    required Color axisLabelColor,
    required ThemeData theme,
    required bool needsScroll,
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
      titlesData: _buildTitlesData(
        buckets: buckets,
        showYear: showYear,
        axisLabelColor: axisLabelColor,
        minY: 0,
        maxY: maxY,
        interval: maxY / 4,
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
              color: MonthlyIncomeExpenseBarChart.revenueColor,
              width: 10,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(3)),
            ),
            BarChartRodData(
              toY: bucket.expense,
              color: MonthlyIncomeExpenseBarChart.expenseColor,
              width: 10,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(3)),
            ),
          ],
        );
      }).toList(),
      groupsSpace: _groupsSpace(buckets.length, needsScroll),
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

  BarChartData _buildBalanceChartData({
    required List<MonthlyIncomeExpenseBucket> buckets,
    required MonthlyIncomeExpenseAxisRange axisRange,
    required bool showYear,
    required Color axisLabelColor,
    required ThemeData theme,
    required bool needsScroll,
  }) {
    final minY = axisRange.minY;
    final maxY = axisRange.maxY;
    final interval = axisRange.interval;

    return BarChartData(
      maxY: maxY,
      minY: minY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (value) {
          final isZeroLine = value.abs() < 0.001;
          return FlLine(
            color: isZeroLine
                ? (theme.brightness == Brightness.dark
                    ? Colors.grey.shade600
                    : Colors.grey.shade400)
                : (theme.brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200),
            strokeWidth: isZeroLine ? 1.5 : 1,
          );
        },
      ),
      borderData: FlBorderData(show: false),
      titlesData: _buildTitlesData(
        buckets: buckets,
        showYear: showYear,
        axisLabelColor: axisLabelColor,
        minY: minY,
        maxY: maxY,
        interval: interval,
      ),
      barGroups: buckets.asMap().entries.map((entry) {
        final index = entry.key;
        final bucket = entry.value;
        final balance = bucket.balance;
        final isPositive = balance >= 0;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              fromY: 0,
              toY: balance,
              color: isPositive
                  ? MonthlyIncomeExpenseBarChart.revenueColor
                  : MonthlyIncomeExpenseBarChart.expenseColor,
              width: 16,
              borderRadius: isPositive
                  ? const BorderRadius.vertical(top: Radius.circular(3))
                  : const BorderRadius.vertical(bottom: Radius.circular(3)),
            ),
          ],
        );
      }).toList(),
      groupsSpace: _groupsSpace(buckets.length, needsScroll),
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
            final label = MonthlyIncomeExpenseChartData.formatMonthLabel(
              bucket.month,
              showYear: showYear,
            );

            return BarTooltipItem(
              '$label\nSaldo: ${MonthlyIncomeExpenseChartData.formatSignedBalance(bucket.balance)}',
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

  FlTitlesData _buildTitlesData({
    required List<MonthlyIncomeExpenseBucket> buckets,
    required bool showYear,
    required Color axisLabelColor,
    required double minY,
    required double maxY,
    required double interval,
  }) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 36,
          interval: interval,
          getTitlesWidget: (value, meta) {
            if (value < minY - 0.001 || value > maxY + 0.001) {
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
    );
  }

  double _groupsSpace(int bucketCount, bool needsScroll) {
    return bucketCount <= MonthlyIncomeExpenseChartData.scrollThresholdMonths
        ? 16
        : 12;
  }
}

class _ChartModeToggle extends StatelessWidget {
  final MonthlyIncomeExpenseChartMode mode;
  final ValueChanged<MonthlyIncomeExpenseChartMode> onChanged;

  const _ChartModeToggle({
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ??
        Colors.grey.shade600;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleSegment(
          icon: FontAwesomeIcons.chartSimple,
          tooltip: 'Comparativo',
          isSelected: mode == MonthlyIncomeExpenseChartMode.comparative,
          inactiveColor: inactiveColor,
          onTap: () => onChanged(MonthlyIncomeExpenseChartMode.comparative),
        ),
        const SizedBox(width: 8),
        _ToggleSegment(
          icon: FontAwesomeIcons.scaleBalanced,
          tooltip: 'Saldo',
          isSelected: mode == MonthlyIncomeExpenseChartMode.balance,
          inactiveColor: inactiveColor,
          onTap: () => onChanged(MonthlyIncomeExpenseChartMode.balance),
        ),
      ],
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isSelected;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _ToggleSegment({
    required this.icon,
    required this.tooltip,
    required this.isSelected,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: FaIcon(
            icon,
            size: 18,
            color: isSelected ? Styles.primaryColor : inactiveColor,
          ),
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final MonthlyIncomeExpenseChartMode mode;
  final ThemeData theme;

  const _ChartLegend({
    required this.mode,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == MonthlyIncomeExpenseChartMode.balance) {
      return Row(
        children: [
          _LegendItem(
            color: MonthlyIncomeExpenseBarChart.revenueColor,
            label: 'Positivo',
            theme: theme,
          ),
          const SizedBox(width: 16),
          _LegendItem(
            color: MonthlyIncomeExpenseBarChart.expenseColor,
            label: 'Negativo',
            theme: theme,
          ),
        ],
      );
    }

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

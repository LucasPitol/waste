import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/modules/home/widgets/daily_income_expense/daily_income_expense_bar_chart_skeleton.dart';
import 'package:meudin_ai_app/modules/home/widgets/daily_income_expense/daily_income_expense_chart_data.dart';
import 'package:meudin_ai_app/modules/insights/widgets/monthly_income_expense/monthly_income_expense_bar_chart.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:meudin_ai_app/utils/utils.dart';

class DailyIncomeExpenseBarChart extends StatefulWidget {
  final List<Transaction> transactions;
  final DateTime startDate;
  final DateTime endDate;
  final bool loading;

  const DailyIncomeExpenseBarChart({
    super.key,
    required this.transactions,
    required this.startDate,
    required this.endDate,
    this.loading = false,
  });

  @override
  State<DailyIncomeExpenseBarChart> createState() =>
      _DailyIncomeExpenseBarChartState();
}

class _DailyIncomeExpenseBarChartState
    extends State<DailyIncomeExpenseBarChart> {
  DailyIncomeExpenseChartMode _mode = DailyIncomeExpenseChartMode.expense;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToEnd();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DailyIncomeExpenseBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endDate != widget.endDate ||
        oldWidget.startDate != widget.startDate ||
        oldWidget.loading != widget.loading ||
        oldWidget.transactions.length != widget.transactions.length) {
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.positions.last;
      position.jumpTo(position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const DailyIncomeExpenseBarChartSkeleton();
    }

    if (widget.transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final buckets = DailyIncomeExpenseChartData.groupByDay(
      transactions: widget.transactions,
      startDate: widget.startDate,
      endDate: widget.endDate,
    );

    if (buckets.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final axisLabelColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.5) ??
        Colors.grey.shade500;
    final scrollGroupWidth =
        DailyIncomeExpenseChartData.scrollGroupWidthFor(_mode);
    final maxY = DailyIncomeExpenseChartData.calculateMaxY(
      buckets,
      mode: _mode,
    );

    final chartData = _mode == DailyIncomeExpenseChartMode.expense
        ? _buildExpenseChartData(
            buckets: buckets,
            maxY: maxY,
            axisLabelColor: axisLabelColor,
            theme: theme,
          )
        : _buildComparativeChartData(
            buckets: buckets,
            maxY: maxY,
            axisLabelColor: axisLabelColor,
            theme: theme,
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
                  _mode == DailyIncomeExpenseChartMode.expense
                      ? 'Despesas por dia'
                      : 'Receitas x Despesas por dia',
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
                onChanged: (mode) {
                  setState(() => _mode = mode);
                  _scrollToEnd();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ChartLegend(mode: _mode, theme: theme),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: SizedBox(
                  key: ValueKey(_mode),
                  width: buckets.length * scrollGroupWidth,
                  height: 200,
                  child: chart,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartData _buildExpenseChartData({
    required List<DailyIncomeExpenseBucket> buckets,
    required double maxY,
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
      titlesData: _buildTitlesData(
        buckets: buckets,
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
          barRods: [
            BarChartRodData(
              toY: bucket.expense,
              color: MonthlyIncomeExpenseBarChart.expenseColor,
              width: 12,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(3)),
            ),
          ],
        );
      }).toList(),
      groupsSpace: 8,
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
            final label = DailyIncomeExpenseChartData.formatTooltipDate(bucket.day);

            return BarTooltipItem(
              '$label\nDespesa: ${Utils.getAmountFormated(bucket.expense)}',
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

  BarChartData _buildComparativeChartData({
    required List<DailyIncomeExpenseBucket> buckets,
    required double maxY,
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
      titlesData: _buildTitlesData(
        buckets: buckets,
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
      groupsSpace: 8,
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
            final label = DailyIncomeExpenseChartData.formatTooltipDate(bucket.day);

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

  FlTitlesData _buildTitlesData({
    required List<DailyIncomeExpenseBucket> buckets,
    required Color axisLabelColor,
    required double minY,
    required double maxY,
    required double interval,
  }) {
    return FlTitlesData(
      topTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 10,
          getTitlesWidget: (_, __) => const SizedBox.shrink(),
        ),
      ),
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

            final isTopTick = (maxY - value).abs() < 0.001;

            return Transform.translate(
              offset: Offset(0, isTopTick ? 5 : 0),
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  DailyIncomeExpenseChartData.formatCompactAxisValue(value),
                  style: TextStyle(
                    fontSize: 10,
                    color: axisLabelColor,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= buckets.length) {
              return const SizedBox.shrink();
            }

            final day = buckets[index].day;

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                DailyIncomeExpenseChartData.formatBottomAxisLabel(
                  day: day,
                  index: index,
                  totalDays: buckets.length,
                ),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: axisLabelColor,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChartModeToggle extends StatelessWidget {
  final DailyIncomeExpenseChartMode mode;
  final ValueChanged<DailyIncomeExpenseChartMode> onChanged;

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
          icon: AppIcons.arrowTrendDown,
          tooltip: 'Despesas',
          isSelected: mode == DailyIncomeExpenseChartMode.expense,
          inactiveColor: inactiveColor,
          onTap: () => onChanged(DailyIncomeExpenseChartMode.expense),
        ),
        const SizedBox(width: 8),
        _ToggleSegment(
          icon: AppIcons.chartSimple,
          tooltip: 'Receitas x Despesas',
          isSelected: mode == DailyIncomeExpenseChartMode.comparative,
          inactiveColor: inactiveColor,
          onTap: () => onChanged(DailyIncomeExpenseChartMode.comparative),
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
          child: AppIcon(
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
  final DailyIncomeExpenseChartMode mode;
  final ThemeData theme;

  const _ChartLegend({
    required this.mode,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (mode == DailyIncomeExpenseChartMode.expense) {
      return _LegendItem(
        color: MonthlyIncomeExpenseBarChart.expenseColor,
        label: 'Despesa',
        theme: theme,
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

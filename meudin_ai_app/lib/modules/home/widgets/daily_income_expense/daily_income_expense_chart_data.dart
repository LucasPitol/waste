import 'package:intl/intl.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/modules/insights/widgets/monthly_income_expense/monthly_income_expense_chart_data.dart';
import 'package:meudin_ai_app/utils/constants.dart';

enum DailyIncomeExpenseChartMode { expense, comparative }

class DailyIncomeExpenseBucket {
  final DateTime day;
  final double revenue;
  final double expense;

  const DailyIncomeExpenseBucket({
    required this.day,
    required this.revenue,
    required this.expense,
  });
}

class DailyIncomeExpenseChartData {
  static const double expenseScrollGroupWidth = 28;
  static const double comparativeScrollGroupWidth = 44;

  static List<DailyIncomeExpenseBucket> groupByDay({
    required List<Transaction> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final rangeStart = DateTime(startDate.year, startDate.month, startDate.day);
    final rangeEnd = _effectiveEndDate(endDate);

    if (rangeStart.isAfter(rangeEnd)) {
      return [];
    }

    final days = _enumerateDays(rangeStart, rangeEnd);
    final totals = {
      for (final day in days) _dayKey(day): _DayTotals(),
    };

    for (final transaction in transactions) {
      final date = transaction.transactionDate;
      final amount = transaction.amount;
      if (date == null || amount == null) continue;

      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (normalizedDate.isBefore(rangeStart) ||
          normalizedDate.isAfter(rangeEnd)) {
        continue;
      }

      final key = _dayKey(normalizedDate);
      final bucket = totals[key];
      if (bucket == null) continue;

      if (amount > 0) {
        bucket.revenue += amount;
      } else if (amount < 0) {
        bucket.expense += amount.abs();
      }
    }

    return days
        .map((day) {
          final bucket = totals[_dayKey(day)]!;
          return DailyIncomeExpenseBucket(
            day: day,
            revenue: bucket.revenue,
            expense: bucket.expense,
          );
        })
        .toList();
  }

  /// Never includes days after today.
  static DateTime _effectiveEndDate(DateTime endDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    return normalizedEnd.isAfter(today) ? today : normalizedEnd;
  }

  static String formatDayLabel(DateTime day) => '${day.day}';

  static String formatBottomAxisLabel({
    required DateTime day,
    required int index,
    required int totalDays,
  }) {
    if (index >= totalDays - 5) {
      return _formatWeekdayAbbrev(day) ?? formatDayLabel(day);
    }
    return formatDayLabel(day);
  }

  static String formatTooltipDate(DateTime day) {
    final weekday = _formatWeekdayAbbrev(day);
    final date = DateFormat('d MMM', Constants.ptLanguageCode).format(day);
    return weekday == null ? date : '$weekday, $date';
  }

  static String? _formatWeekdayAbbrev(DateTime day) {
    final weekday = DateFormat('EEE', Constants.ptLanguageCode).format(day);
    final cleaned = weekday.replaceAll('.', '').trim();
    if (cleaned.isEmpty) return null;
    return '${cleaned[0].toUpperCase()}${cleaned.substring(1)}';
  }

  static String formatCompactAxisValue(double value) =>
      MonthlyIncomeExpenseChartData.formatCompactAxisValue(value);

  static double calculateMaxY(
    List<DailyIncomeExpenseBucket> buckets, {
    required DailyIncomeExpenseChartMode mode,
  }) {
    var maxValue = 0.0;
    for (final bucket in buckets) {
      if (mode == DailyIncomeExpenseChartMode.expense) {
        if (bucket.expense > maxValue) maxValue = bucket.expense;
      } else {
        if (bucket.revenue > maxValue) maxValue = bucket.revenue;
        if (bucket.expense > maxValue) maxValue = bucket.expense;
      }
    }
    if (maxValue == 0) return 10;
    return maxValue * 1.15;
  }

  static double scrollGroupWidthFor(
    DailyIncomeExpenseChartMode mode, {
    required double viewportWidth,
    required int itemCount,
  }) {
    final minGroupWidth = mode == DailyIncomeExpenseChartMode.expense
        ? expenseScrollGroupWidth
        : comparativeScrollGroupWidth;

    return MonthlyIncomeExpenseChartData.scrollGroupWidthForViewport(
      viewportWidth: viewportWidth,
      itemCount: itemCount,
      minGroupWidth: minGroupWidth,
    );
  }

  static List<DateTime> _enumerateDays(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(last)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  static String _dayKey(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }
}

class _DayTotals {
  double revenue = 0;
  double expense = 0;
}

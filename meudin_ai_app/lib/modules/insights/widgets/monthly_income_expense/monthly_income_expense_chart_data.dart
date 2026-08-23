import 'package:meudin_ai_app/models/transaction.dart';

class MonthlyIncomeExpenseBucket {
  final DateTime month;
  final double revenue;
  final double expense;

  const MonthlyIncomeExpenseBucket({
    required this.month,
    required this.revenue,
    required this.expense,
  });
}

class MonthlyIncomeExpenseChartData {
  static const _monthLabels = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  static const int scrollThresholdMonths = 12;
  static const double scrollGroupWidth = 56;

  static List<MonthlyIncomeExpenseBucket> groupByMonth({
    required List<Transaction> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final months = _enumerateMonths(startDate, endDate);
    final totals = {
      for (final month in months) _monthKey(month): _MonthTotals(),
    };

    final rangeStart = DateTime(startDate.year, startDate.month, startDate.day);
    final rangeEnd = DateTime(endDate.year, endDate.month, endDate.day);

    for (final transaction in transactions) {
      final date = transaction.transactionDate;
      final amount = transaction.amount;
      if (date == null || amount == null) continue;

      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (normalizedDate.isBefore(rangeStart) || normalizedDate.isAfter(rangeEnd)) {
        continue;
      }

      final key = _monthKey(DateTime(date.year, date.month));
      final bucket = totals[key];
      if (bucket == null) continue;

      if (amount > 0) {
        bucket.revenue += amount;
      } else if (amount < 0) {
        bucket.expense += amount.abs();
      }
    }

    return months
        .map((month) {
          final bucket = totals[_monthKey(month)]!;
          return MonthlyIncomeExpenseBucket(
            month: month,
            revenue: bucket.revenue,
            expense: bucket.expense,
          );
        })
        .toList();
  }

  static String formatMonthLabel(
    DateTime month, {
    required bool showYear,
  }) {
    final label = _monthLabels[month.month - 1];
    if (!showYear) return label;
    final yearSuffix = (month.year % 100).toString().padLeft(2, '0');
    return '$label/$yearSuffix';
  }

  static String formatCompactAxisValue(double value) {
    if (value == 0) return '0';

    final absValue = value.abs();
    if (absValue >= 1000000) {
      final formatted = absValue / 1000000;
      return '${_trimTrailingZero(formatted)}M';
    }
    if (absValue >= 1000) {
      final formatted = absValue / 1000;
      return '${_trimTrailingZero(formatted)}k';
    }
    return absValue.toStringAsFixed(0);
  }

  static double calculateMaxY(List<MonthlyIncomeExpenseBucket> buckets) {
    var maxValue = 0.0;
    for (final bucket in buckets) {
      if (bucket.revenue > maxValue) maxValue = bucket.revenue;
      if (bucket.expense > maxValue) maxValue = bucket.expense;
    }
    if (maxValue == 0) return 10;
    return maxValue * 1.15;
  }

  static List<DateTime> _enumerateMonths(DateTime start, DateTime end) {
    final months = <DateTime>[];
    var current = DateTime(start.year, start.month);
    final last = DateTime(end.year, end.month);

    while (!current.isAfter(last)) {
      months.add(current);
      current = current.month == 12
          ? DateTime(current.year + 1, 1)
          : DateTime(current.year, current.month + 1);
    }

    return months;
  }

  static String _monthKey(DateTime month) {
    return '${month.year}-${month.month.toString().padLeft(2, '0')}';
  }

  static String _trimTrailingZero(double value) {
    final text = value.toStringAsFixed(1);
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }
}

class _MonthTotals {
  double revenue = 0;
  double expense = 0;
}

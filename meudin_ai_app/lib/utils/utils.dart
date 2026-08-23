import 'package:intl/intl.dart';
import 'package:meudin_ai_app/utils/constants.dart';
import 'package:money_formatter/money_formatter.dart';

class Utils {
  static String getAmountFormated(double amount) {
    return MoneyFormatter(amount: amount).output.nonSymbol;
  }

  static String formatDateMMMdeYYYY(DateTime? value) {
    if (value == null) {
      return Constants.EMPTY_STRING;
    } else {
      return DateFormat.yMMMM(Constants.ptLanguageCode).format(value);
    }
  }

  static String formatDateDDMMYY(DateTime? value) {
    if (value == null) {
      return Constants.EMPTY_STRING;
    } else {
      return DateFormat.yMd(Constants.ptLanguageCode).format(value);
    }
  }

  static String formatTransactionListDate(DateTime? value) {
    if (value == null) {
      return Constants.EMPTY_STRING;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(value.year, value.month, value.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return 'Hoje';
    if (date == yesterday) return 'Ontem';

    const monthLabels = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];

    return '${value.day} ${monthLabels[value.month - 1]}';
  }
}

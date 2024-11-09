import 'package:intl/intl.dart';
import 'package:meudin_ai_app/utils/constants.dart';
import 'package:money_formatter/money_formatter.dart';

class Utils {
  static String getAmountFormated(double amount) {
    return MoneyFormatter(amount: amount).output.nonSymbol;
  }

  static String formatDateDDMMYY(DateTime? value) {
    if (value == null) {
      return Constants.EMPTY_STRING;
    } else {
      return DateFormat.yMd(Constants.ptLanguageCode).format(value);
    }
  }
}

import 'package:intl/intl.dart';
import 'package:meudin_app/services/user_service.dart';
import 'package:meudin_app/models/forms/new_user_form.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import 'constants.dart';

class Utils {
  static String formatDateDDdeMMMdeYYYY(DateTime? value) {
    if (value == null) {
      return Constants.EMPTY_STRING;
    } else {
      return DateFormat.yMMMMd(Constants.ptLanguage).format(value);
    }
  }

  static String formatDateDDMM(DateTime? value) {
    if (value == null) {
      return Constants.EMPTY_STRING;
    } else {
      return DateFormat.yMd(Constants.ptLanguage).add_jm().format(value);
    }
  }

  static String formatAmount(double? value) {
    if (value == null) {
      return Constants.EMPTY_STRING;
    } else {
      return toCurrencyString(value.toString());
    }
  }

  static mockData() async {
    UserService _userService = UserService();

    NewUserForm _newUserForm = NewUserForm();
    _newUserForm.name.text = 'Judas';
    _newUserForm.email.text = 'judas@gmail.com';
    _newUserForm.password.text = '1234567';

    await _userService.createNewUser(_newUserForm);
  }
}

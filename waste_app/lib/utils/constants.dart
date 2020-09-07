import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class Constants {
  static List<String> languages = ['pt', 'en'];

  static String ptLanguage = 'pt_BR';
  static String enLanguage = 'en-GB';

  static Map<String, IconData> categoryIconDict = {
    'bankRate': Icons.account_balance,
    'education': Icons.school,
    'drugStore': Icons.local_pharmacy,
    'food': Icons.fastfood,
    'health': Icons.local_hospital,
    'house': Icons.home,
    'internet': Icons.wifi,
    'market': Icons.shopping_cart,
    'recreation': Icons.local_bar,
    'transport': Icons.directions_bus,
    'salary': Icons.work,
    'shopping': Icons.shopping_basket,
  };

  static IconData getCategoryIcon(String value) {
    return categoryIconDict.containsKey(value)
        ? categoryIconDict[value]
        : Icons.attach_money;
  }

  static String getDefaultEmptyFieldMsg(String language) {
    return language == languages[0] ? 'Campo obrigatório' : 'Required field';
  }

  static String getPasswordNotMatchMsg(String language) {
    return language == languages[0]
        ? 'Senhas não coincidem'
        : "Passwords don't match";
  }

  static String getDefaultInvalidEmailMsg(String language) {
    return language == languages[0] ? 'email inválido' : 'Invalid email';
  }

  static String getUserAlreadyExistsMsg(String language) {
    return language == languages[0]
        ? 'email já cadastrado'
        : 'email already registered';
  }

  static String getAmountFormated(double amount) {
    return toCurrencyString(amount.toString());
  }
}

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
    'vehicle': Icons.directions_car,
    'salary': Icons.work,
    'shopping': Icons.shopping_basket,
  };

  static List<Color> chartColorList = [
    Colors.deepPurple[900],
    Colors.deepPurple,
    Colors.deepPurple[300],
    Colors.deepPurple[100],
  ];

  static int maximumTransactionsDiplayCount = 20;

  static int sixMonthsInDays = 180;

  static int walletMembersLimit = 2;

  static int numberOfWalletsLimit = 3;

  static getDefaultLoadingWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 60),
      width: double.infinity,
      alignment: Alignment.center,
      child: Theme(
        data: Theme.of(context).copyWith(accentColor: Colors.deepPurple),
        child: new CircularProgressIndicator(),
      ),
    );
  }

  static IconData getCategoryIcon(String value) {
    return categoryIconDict.containsKey(value)
        ? categoryIconDict[value]
        : Icons.attach_money;
  }

  static String getDefaultEmptyFieldMsg(bool isPt) {
    return isPt ? 'Campo obrigatório' : 'Required field';
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

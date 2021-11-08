import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Constants {
  static const String EMPTY_STRING = '---';

  static String ptLanguage = 'pt_BR';

  static int numberOfWalletsLimitOnFreePlan = 2;

  static String getDefaultEmptyFieldMsg() {
    return 'Campo obrigatório';
  }

  static String getDefaultInvalidEmailMsg() {
    return 'email inválido';
  }

  static Map<String, IconData> categoryIconDict = {
    'bankRate': FontAwesomeIcons.university,
    'education': FontAwesomeIcons.school,
    'drugStore': FontAwesomeIcons.prescriptionBottle,
    'food': FontAwesomeIcons.hamburger,
    'health': FontAwesomeIcons.firstAid,
    'house': FontAwesomeIcons.home,
    'internet': FontAwesomeIcons.wifi,
    'market': FontAwesomeIcons.shoppingCart,
    'recreation': FontAwesomeIcons.glassCheers,
    'transport': FontAwesomeIcons.bus,
    'payroll': FontAwesomeIcons.briefcase,
    'shopping': FontAwesomeIcons.shoppingBag,
    'vehicle': FontAwesomeIcons.car,
  };

  static IconData? getCategoryIcon(String value) {
    return categoryIconDict.containsKey(value)
        ? categoryIconDict[value]
        : FontAwesomeIcons.dollarSign;
  }
}

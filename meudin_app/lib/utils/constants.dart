import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Constants {
  static const String EMPTY_STRING = '---';

  static const String privacyPolicyUrl =
      'https://docs.google.com/document/d/13ZYtEePL_mwjZRxZYyNcEhse7U05utQDpqHX9yVqLwM/edit?usp=sharing';

  static const String instagramUrl = 'https://www.instagram.com/meudin.app/';

  static String ptLanguage = 'pt_BR';

  static int numberOfWalletsLimitOnFreePlan = 2;

  static String getDefaultEmptyFieldMsg() {
    return 'Campo obrigatório';
  }

  static String getDefaultInvalidEmailMsg() {
    return 'email inválido';
  }

  static Map<int, String> monthDict = {
    1: 'Janeiro',
    2: 'Fevereiro',
    3: 'Março',
    4: 'Abril',
    5: 'Maio',
    6: 'Junho',
    7: 'Julho',
    8: 'Agosto',
    9: 'Setembro',
    10: 'Outubro',
    11: 'Novembro',
    12: 'Dezembro',
  };

  static List<int> years = [2018, 2019, 2020, 2021, 2022];

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

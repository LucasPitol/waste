import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class Constants {
  static List<String> languages = ['pt', 'en'];

  static String ptLanguage = 'pt_BR';
  static String enLanguage = 'en-GB';

  static String getDefaultEmptyFieldMsg(String language) {
    return language == languages[0] ? 'Campo obrigatório' : 'Required field';
  }

  static String getPasswordNotMatchMsg(String language) {
    return language == languages[0] ? 'Senhas não coincidem' : "Passwords don't match";
  }

  static String getDefaultInvalidEmailMsg(String language) {
    return language == languages[0] ? 'email inválido' : 'Invalid email';
  }

  static String getUserAlreadyExistsMsg(String language) {
    return language == languages[0] ? 'email já cadastrado' : 'email already registered';
  }

  static String getAmountFormated(double amount) {
    return toCurrencyString(amount.toString());
  }
}
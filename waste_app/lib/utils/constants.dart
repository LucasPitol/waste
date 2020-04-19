class Constants {
  static List<String> languages = ['Português', 'English'];

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
}
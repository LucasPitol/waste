class NewUserDto {
  late String name;
  late String email;
  late String password;

  NewUserDto() {
    name = '';
    email = '';
    password = '';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }
}

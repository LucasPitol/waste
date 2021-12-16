class NewUserDto {
  late String name;
  late String email;
  late String password;

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'email': this.email,
      'password': this.password,
    };
  }
}

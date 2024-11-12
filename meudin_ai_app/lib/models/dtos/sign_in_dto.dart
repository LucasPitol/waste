import 'package:flutter/material.dart';

class SignInDto {
  late TextEditingController email;
  late TextEditingController password;

  SignInDto() {
    email = TextEditingController();
    password = TextEditingController();
  }
}

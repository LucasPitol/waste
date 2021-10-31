import 'package:flutter/material.dart';

class LoginForm {
  late TextEditingController userMail;
  late TextEditingController password;

  LoginForm() {
    userMail = TextEditingController();
    password = TextEditingController();
  }
}

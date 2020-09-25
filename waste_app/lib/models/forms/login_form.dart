import 'package:flutter/material.dart';

class LoginForm {
  TextEditingController userMail;
  TextEditingController password;

  LoginForm() {
    this.userMail = new TextEditingController();
    this.password = new TextEditingController();
  }
}
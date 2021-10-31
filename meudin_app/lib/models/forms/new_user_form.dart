import 'package:flutter/material.dart';

class NewUserForm {
  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController password;

  NewUserForm() {
    name = TextEditingController();
    email = TextEditingController();
    password = TextEditingController();
  }
}
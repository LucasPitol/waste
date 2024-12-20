import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecoverPasswordPageController extends GetxController {
  late TextEditingController userMailController;
  late bool loading;

  RecoverPasswordPageController(String? userMail) {
    userMailController = TextEditingController();

    if (userMail != null) {
      userMailController.text = userMail;
    }
    loading = false;
  }
}

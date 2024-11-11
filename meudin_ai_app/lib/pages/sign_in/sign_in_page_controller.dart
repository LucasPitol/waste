import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInPageController extends GetxController {
  final formKey = GlobalKey<FormState>();
  late bool loading;


  SignInPageController() {
    loading = false;
  }
}

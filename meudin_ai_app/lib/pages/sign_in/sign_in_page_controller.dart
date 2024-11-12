import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/models/dtos/sign_in_dto.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';

class SignInPageController extends GetxController {
  final formKey = GlobalKey<FormState>();
  late SignInDto signInDto;
  late bool loading;

  SignInPageController() {
    signInDto = SignInDto();
    loading = false;
  }

  signIn() {
    print('sign in');
  }

  goToSignUpPage() async {
    final signInDtoTemp = await Get.toNamed(AppRoutes.signUpRoute);

    if (signInDtoTemp != null) {
      print('signIn');
    }
  }

  recoverPassword() {
    print('recover password');
  }
}

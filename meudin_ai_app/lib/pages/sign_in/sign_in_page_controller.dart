import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/models/dtos/sign_in_dto.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class SignInPageController extends GetxController {
  final formKey = GlobalKey<FormState>();
  late SignInDto signInDto;
  late bool loading;
  late UserService _userService;

  SignInPageController() {
    signInDto = SignInDto();
    loading = false;
    _userService = UserService();
  }

  signIn(String email, String password) async {
    loading = true;
    update();

    final authResponse = await _userService.signInByEmailAndPassword(
      email,
      password,
    );

    if (authResponse.success) {
      await Get.offNamed(AppRoutes.homeAppRoute);
    } else {
      loading = false;
      update();

      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: [authResponse.errorMessage!],
        title: 'Não foi possível fazer a autenticação :(',
      );
    }
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

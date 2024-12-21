import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/pages/recover_password/widgets/mail_step_widget.dart';
import 'package:meudin_ai_app/pages/recover_password/widgets/new_password_step_widget.dart';
import 'package:meudin_ai_app/pages/sign_up/widgets/verification_code_step_widget.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class RecoverPasswordPageController extends GetxController {
  late bool loading;
  late Widget currentStepWidget;
  late List<Widget> signUpWidgets = [];
  late int currentStep;
  late UserService _userService;
  late String userMail;

  RecoverPasswordPageController(String? userMailTyped) {
    _userService = UserService();
    userMail = '';

    signUpWidgets = [
      MailStepWidget(nextStep: retriveUserMail, userMail: userMailTyped),
      Container(),
      NewPasswordStepWidget(nextStep: retriveUserNewPassword),
    ];
    currentStep = 0;
    currentStepWidget = signUpWidgets[currentStep];

    if (userMailTyped != null) {
      userMail = userMailTyped;
    }
    loading = false;
  }

  retriveUserMail(String? userMailTemp) {
    List<String> errors = validateUserInfoForm(userMailTemp);

    if (errors.isNotEmpty) {
      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: errors,
        title: 'Revise as informações preenchidas',
      );
    } else {
      userMail = userMailTemp!;

      signUpWidgets[1] = VerificationCodeStepWidget(
          nextStep: retriveVerificationCode, userMail: userMail);

      _userService.sendVerificationCode(
          userMail: userMail, verificationType: 'CHANGE_PASSWORD');

      moveToNextStep();
    }
  }

  validateUserInfoForm(String? userMailTemp) {
    List<String> errorList = [];

    if (userMailTemp == null || userMailTemp.trim().isEmpty) {
      errorList.add('Preencha o campo email');
    } else {
      if (!userMailTemp.isEmail) {
        errorList.add('Email inválido, verifique o campo preenchido');
      }
    }

    return errorList;
  }

  retriveVerificationCode(String? verificationCode) async {
    if (verificationCode != null && verificationCode.length == 6) {
      loading = true;
      update();

      final verificationCodeResponse =
          await _userService.validateVerificationCode(
        userMail: userMail,
        verificationCode: verificationCode,
      );

      loading = false;

      if (verificationCodeResponse.success) {
        moveToNextStep();
      } else {
        JoyModal.bottomSheetError(
          context: Get.context!,
          errorList: [verificationCodeResponse.errorMessage!],
          title: 'Revise as informações preenchidas',
        );
      }
      update();
    } else {
      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: ['Código inválido'],
        title: 'Revise as informações preenchidas',
      );
    }
  }

  retriveUserNewPassword(String? password, String? repassword) {
    loading = true;
    update();

    List<String> errors = [];

    if (password == null || repassword == null) {
      errors.add('Preencha os 2 campos');
    } else {
      if (password != repassword) {
        errors.add('Digite a mesma senha nos 2 campos');
      }

      if (password.length < 6) {
        errors.add('A senha deve ter pelo menos 6 caracteres');
      }
    }

    if (errors.isNotEmpty) {
      loading = false;
      update();

      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: errors,
        title: 'Revise as informações preenchidas',
      );
    } else {
      _userService.updateUserPassword(
        userMail: userMail,
        newPassword: password!,
      );
      Get.back();
    }
  }

  moveToNextStep() {
    currentStep++;
    currentStepWidget = signUpWidgets[currentStep];
    update();
  }
}

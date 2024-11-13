import 'package:meudin_ai_app/pages/sign_up/widgets/verification_code_step_widget.dart';
import 'package:meudin_ai_app/pages/sign_up/widgets/password_step_widget.dart';
import 'package:meudin_ai_app/pages/sign_up/widgets/mail_step_widget.dart';
import 'package:meudin_ai_app/models/dtos/new_user_dto.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPageController extends GetxController {
  late bool loading;
  late Widget currentStepWidget;
  late List<Widget> signUpWidgets = [];
  late int currentStep;
  late NewUserDto newUserDto;

  SignUpPageController() {
    loading = false;
    newUserDto = NewUserDto();

    signUpWidgets = [
      MailStepWidget(nextStep: retriveUserMail),
      VerificationCodeStepWidget(
          nextStep: retriveVerificationCode, userMail: newUserDto.email),
      PasswordStepWidget(nextStep: retriveUserPassword),
    ];
    currentStep = 0;
    currentStepWidget = signUpWidgets[currentStep];
  }

  retriveUserMail(String? userMail) {
    var errors = validateMailForm(userMail);

    if (errors.isNotEmpty) {
      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: errors,
        title: 'Revise as informações preenchidas',
      );
    } else {
      newUserDto.email = userMail!;
      signUpWidgets[1] = VerificationCodeStepWidget(
          nextStep: retriveVerificationCode, userMail: newUserDto.email);
      // _userService.sendVerificationCode(userMail: userMail);

      moveToNextStep();
    }
  }

  validateMailForm(String? userMail) {
    List<String> errorList = [];

    if (userMail == null || userMail.trim().isEmpty) {
      errorList.add('Preencha o campo email');
    } else {
      if (!userMail.isEmail) {
        errorList.add('Email inválido, verifique o campo preenchido');
      }
    }

    return errorList;
  }

  retriveVerificationCode(String? verificationCode) {
    if (verificationCode != null && verificationCode.length == 6) {
      moveToNextStep();
    } else {
      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: ['Código inválido'],
        title: 'Revise as informações preenchidas',
      );
    }
  }

  retriveUserPassword(String? password, String? repassword) {
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
      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: errors,
        title: 'Revise as informações preenchidas',
      );
    } else {
      _createUser();
    }
  }

  _createUser() {
    print('Create user');
  }

  moveToNextStep() {
    currentStep++;
    currentStepWidget = signUpWidgets[currentStep];
    update();
  }
}

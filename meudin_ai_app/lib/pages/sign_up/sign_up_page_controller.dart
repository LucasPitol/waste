import 'package:meudin_ai_app/models/dtos/new_user_dto.dart';
import 'package:meudin_ai_app/pages/sign_up/widgets/mail_step_widget.dart';
import 'package:meudin_ai_app/pages/sign_up/widgets/verification_code_step_widget.dart';
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
      Container(child: Text('3')),
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
      _fillWidgets();
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

  moveToNextStep() {
    currentStep++;
    currentStepWidget = signUpWidgets[currentStep];
    update();
  }

  _fillWidgets() {
    signUpWidgets = [
      MailStepWidget(nextStep: retriveUserMail),
      VerificationCodeStepWidget(
          nextStep: retriveVerificationCode, userMail: newUserDto.email),
      Container(child: Text('3')),
    ];

    update();
  }

  @override
  void onInit() {
    super.onInit();
    _fillWidgets();
  }
}

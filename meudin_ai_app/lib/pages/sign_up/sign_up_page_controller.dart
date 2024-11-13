import 'package:meudin_ai_app/pages/sign_up/widgets/mail_step_widget.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPageController extends GetxController {
  late bool loading;
  late Widget currentStepWidget;
  late List<Widget> signUpWidgets = [];
  late int currentStep;

  SignUpPageController() {
    loading = false;
    signUpWidgets = [
      MailStepWidget(nextStep: retriveUserMail),
      Container(child: Text('2')),
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

      // newUserDto = NewUserDto(name: nameAndSurname, email: userMail!);
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

  moveToNextStep() {
    currentStep++;
    currentStepWidget = signUpWidgets[currentStep];
    update();
  }
}

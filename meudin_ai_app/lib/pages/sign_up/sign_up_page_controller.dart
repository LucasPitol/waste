import 'package:meudin_ai_app/pages/sign_up/widgets/verification_code_step_widget.dart';
import 'package:meudin_ai_app/pages/sign_up/widgets/password_step_widget.dart';
import 'package:meudin_ai_app/pages/sign_up/widgets/mail_step_widget.dart';
import 'package:meudin_ai_app/models/dtos/new_user_dto.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPageController extends GetxController {
  late bool loading;
  late Widget currentStepWidget;
  late List<Widget> signUpWidgets = [];
  late int currentStep;
  late NewUserDto newUserDto;
  late UserService _userService;

  SignUpPageController() {
    loading = false;
    newUserDto = NewUserDto();
    _userService = UserService();

    signUpWidgets = [
      MailStepWidget(nextStep: retriveUserInfo),
      Container(),
      PasswordStepWidget(nextStep: retriveUserPassword),
    ];
    currentStep = 0;
    currentStepWidget = signUpWidgets[currentStep];
  }

  retriveUserInfo(String? userMail, String? userName) {
    List<String> errors = validateUserInfoForm(userMail, userName);

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
      _userService.sendVerificationCode(
          userMail: userMail, verificationType: 'NEW_USER');

      moveToNextStep();
    }
  }

  validateUserInfoForm(String? userMail, String? userName) {
    List<String> errorList = [];

    if (userMail == null || userMail.trim().isEmpty) {
      errorList.add('Preencha o campo email');
    } else {
      if (!userMail.isEmail) {
        errorList.add('Email inválido, verifique o campo preenchido');
      }
    }

    if (userName == null || userName.trim().isEmpty) {
      errorList.add('Preencha o campo nome');
    }

    return errorList;
  }

  retriveVerificationCode(String? verificationCode) async {
    if (verificationCode != null && verificationCode.length == 6) {
      loading = true;
      update();

      final verificationCodeResponse =
          await _userService.validateVerificationCode(
        userMail: newUserDto.email,
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
      newUserDto.password = password!;
      _createUser();
    }
  }

  _createUser() async {
    loading = true;
    update();

    final createNewUserResponse = await _userService.createNewUser(newUserDto);

    if (createNewUserResponse.success) {
      final authResponse = await _userService.signInByEmailAndPassword(
        newUserDto.email,
        newUserDto.password,
      );

      if (authResponse.success) {
        await Get.offNamed(AppRoutes.homeAppRoute);
      } else {
        loading = false;
        update();

        JoyModal.bottomSheetError(
          context: Get.context!,
          errorList: [authResponse.errorMessage!],
          title: 'Não foi fazer a autenticação :(',
        );
      }
    } else {
      loading = false;
      update();

      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: [createNewUserResponse.errorMessage!],
        title: 'Não foi possível criar o usuário :(',
      );
    }
  }

  moveToNextStep() {
    currentStep++;
    currentStepWidget = signUpWidgets[currentStep];
    update();
  }
}

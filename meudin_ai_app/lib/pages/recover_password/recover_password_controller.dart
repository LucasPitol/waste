import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/pages/recover_password/widgets/mail_step_widget.dart';
import 'package:meudin_ai_app/pages/recover_password/widgets/new_password_step_widget.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

// ⚠️ ATENÇÃO: Este controller precisa ser refatorado para usar o sistema de
// recuperação de senha do Supabase (email magic link)
// Por enquanto, a funcionalidade está desabilitada

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
      Future.microtask(() {
        Get.bottomSheet(
          JoyModal.errorBottomSheet(
            context: Get.context!,
            errorList: errors,
            title: 'Revise as informações preenchidas',
          ),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Colors.transparent,
        );
      });
    } else {
      userMail = userMailTemp!;

      // ⚠️ TODO: Implementar recuperação de senha via Supabase
      // Supabase.auth.resetPasswordForEmail(userMail)
      
      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: ['Funcionalidade em desenvolvimento. Use o Supabase para recuperar senha.'],
        title: 'Em breve',
      );
      return;

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

  // ⚠️ REMOVIDO: Verificação manual de código não é mais necessária

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
      // ⚠️ TODO: Implementar atualização de senha via Supabase
      loading = false;
      update();
      
      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: ['Funcionalidade em desenvolvimento. Use o Supabase para recuperar senha.'],
        title: 'Em breve',
      );
    }
  }

  moveToNextStep() {
    currentStep++;
    currentStepWidget = signUpWidgets[currentStep];
    update();
  }
}

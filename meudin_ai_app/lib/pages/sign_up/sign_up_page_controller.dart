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

    // ✅ SIMPLIFICADO: Apenas 2 etapas (email/nome + senha)
    signUpWidgets = [
      MailStepWidget(nextStep: retriveUserInfo),
      PasswordStepWidget(nextStep: retriveUserPassword),
    ];
    currentStep = 0;
    currentStepWidget = signUpWidgets[currentStep];
  }

  retriveUserInfo(String? userMail, String? userName) {
    List<String> errors = validateUserInfoForm(userMail, userName);

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
      newUserDto.email = userMail!;
      newUserDto.name = userName!;
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

    loading = false;
    update();

    if (createNewUserResponse.success) {
      // ✅ Usuário criado! Mostrar mensagem de sucesso
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 28),
              const SizedBox(width: 12),
              const Text('Conta criada!'),
            ],
          ),
          content: const Text(
            'Verifique seu email para ativar sua conta. '
            'Após a verificação, você poderá fazer login.',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(); // Fecha o diálogo
                Get.back(); // Volta para tela de login
              },
              child: Text(
                'OK, ENTENDI',
                style: TextStyle(
                  color: Styles.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: [createNewUserResponse.errorMessage!],
        title: 'Não foi possível criar o usuário',
      );
    }
  }

  moveToNextStep() {
    currentStep++;
    currentStepWidget = signUpWidgets[currentStep];
    update();
  }
}

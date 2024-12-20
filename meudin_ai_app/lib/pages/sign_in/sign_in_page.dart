import 'package:meudin_ai_app/pages/sign_in/sign_in_page_controller.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignInPageController>(
      init: SignInPageController(),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          top: 20,
                        ),
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            children: [
                              const JoyLogo(),
                              const SizedBox(height: 60),
                              JoyTextFormField(
                                controller: controller.signInDto.email,
                                labelText: 'Email',
                                keyboardType: TextInputType.emailAddress,
                                textCapitalization: TextCapitalization.none,
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: JoyTextFormField(
                                  controller: controller.signInDto.password,
                                  labelText: 'Senha',
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  textCapitalization: TextCapitalization.none,
                                  onFieldSubmitted: () {
                                    controller.signIn(
                                      controller.signInDto.email.text,
                                      controller.signInDto.password.text,
                                    );
                                  },
                                ),
                              ),
                              Container(
                                alignment: Alignment.center,
                                child: JoyElevatedButton(
                                  text: 'Entrar',
                                  function: () {
                                    controller.signIn(
                                      controller.signInDto.email.text,
                                      controller.signInDto.password.text,
                                    );
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    JoyText.secundaryText('Novo por aqui?'),
                                    JoyTextButton(
                                      text: 'Cadastre-se',
                                      function: controller.goToSignUpPage,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    JoyText.secundaryText(
                                        'Esqueceu sua senha?'),
                                    JoyTextButton(
                                      text: 'Recuperar senha',
                                      function: () {
                                        controller.goToRecoverPasswordPage(
                                            controller.signInDto.email.text);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                JoyLoadingBlock(controller.loading),
              ],
            ),
          ),
        );
      },
    );
  }
}

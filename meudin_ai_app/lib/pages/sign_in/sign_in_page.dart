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
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          top: 60,
                        ),
                        child: Form(
                          key: controller.formKey,
                          child: Column(
                            children: [
                              JoyLogo(),
                              
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

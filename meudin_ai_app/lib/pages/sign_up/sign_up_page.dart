import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_ai_app/pages/sign_up/sign_up_page_controller.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignUpPageController>(
      init: SignUpPageController(),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            JoyText.h1('Cadastro'),
                            IconButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.xmark,
                                color: Styles.primaryTextColor,
                                size: 22,
                              ),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 20,
                          top: 60,
                        ),
                        child: Column(
                          children: [
                            const JoyLogo(),
                            const SizedBox(height: 40),
                          ],
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

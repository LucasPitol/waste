import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_ai_app/pages/recover_password/recover_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class RecoverPasswordPage extends StatelessWidget {
  const RecoverPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    String? userMail = arguments['userMail'];

    return GetBuilder<RecoverPasswordPageController>(
      init: RecoverPasswordPageController(userMail),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                SizedBox(
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
                        child: Column(
                          children: [
                            const JoyLogo(),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: controller.currentStepWidget,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.arrowLeft,
                          color: Styles.primaryTextColor,
                          size: 20,
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recuperação de senha',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Styles.primaryTextColor,
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

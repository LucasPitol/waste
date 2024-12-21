import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class MailStepWidget extends StatelessWidget {
  final TextEditingController newUserMailController = TextEditingController();
  final Function nextStep;
  final String? userMail;

  MailStepWidget({super.key, required this.nextStep, this.userMail});

  @override
  Widget build(BuildContext context) {
    if (userMail != null) {
      newUserMailController.text = userMail!;
    }

    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: JoyText.secundaryText('Digite seu email'),
          ),
          JoyTextFormField(
            controller: newUserMailController,
            labelText: 'Email',
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            onFieldSubmitted: () => nextStep(
              newUserMailController.text,
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          JoyElevatedButton(
            text: 'Próximo',
            function: () => nextStep(
              newUserMailController.text,
            ),
          ),
        ],
      ),
    );
  }
}

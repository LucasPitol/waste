import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class MailStepWidget extends StatelessWidget {
  final TextEditingController newUserNameController = TextEditingController();
  final TextEditingController newUserMailController = TextEditingController();
  final Function nextStep;

  MailStepWidget({super.key, required this.nextStep});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: JoyText.secundaryText('Digite seu email'),
          ),
          JoyTextFormField(
            controller: newUserNameController,
            labelText: 'Nome',
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(
            height: 20,
          ),
          JoyTextFormField(
            controller: newUserMailController,
            labelText: 'Email',
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            onFieldSubmitted: () => nextStep(
              newUserMailController.text,
              newUserNameController.text,
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          JoyElevatedButton(
            text: 'Próximo',
            function: () => nextStep(
              newUserMailController.text,
              newUserNameController.text,
            ),
          ),
        ],
      ),
    );
  }
}

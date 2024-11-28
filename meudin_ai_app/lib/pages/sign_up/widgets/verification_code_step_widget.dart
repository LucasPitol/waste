import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class VerificationCodeStepWidget extends StatelessWidget {
  final TextEditingController codeController = TextEditingController();
  final String userMail;
  final Function nextStep;

  VerificationCodeStepWidget(
      {super.key, required this.nextStep, required this.userMail});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: JoyText.secundaryText(
              'Digite o codigo de verificação enviado para $userMail',
              textOverflow: TextOverflow.visible,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: JoyTextFormField(
              controller: codeController,
              labelText: 'Código',
              keyboardType: TextInputType.number,
              textCapitalization: TextCapitalization.none,
              onFieldSubmitted: () => nextStep(
                codeController.text,
              ),
            ),
          ),
          JoyElevatedButton(
            text: 'Próximo',
            function: () => nextStep(
              codeController.text,
            ),
          ),
        ],
      ),
    );
  }
}

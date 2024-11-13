import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';

class PasswordStepWidget extends StatelessWidget {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();
  final Function nextStep;

  PasswordStepWidget({super.key, required this.nextStep});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: JoyText.secundaryText('Quase la!\nCrie sua senha'),
          ),
          JoyTextFormField(
            controller: passwordController,
            labelText: 'Senha',
            keyboardType: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.none,
            obscureText: true,
          ),
          const SizedBox(height: 20,),
          JoyTextFormField(
            controller: rePasswordController,
            labelText: 'Confirme sua senha',
            keyboardType: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.none,
            obscureText: true,
            onFieldSubmitted: nextStep(
              passwordController.text,
              rePasswordController.text,
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          JoyElevatedButton(
            text: 'Finalizar',
            function: () => nextStep(
              passwordController.text,
              rePasswordController.text,
            ),
          ),
        ],
      ),
    );
  }
}

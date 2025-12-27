import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

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
            onFieldSubmitted: () => nextStep(
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text.rich(
              TextSpan(
                text: 'Ao finalizar, você concorda com os ',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey.shade600,
                ),
                children: [
                  TextSpan(
                    text: 'Termos de Uso',
                    style: TextStyle(
                      fontSize: 12,
                      color: Styles.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _openTermsOfUse(context),
                  ),
                  TextSpan(
                    text: ' e a ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey.shade600,
                    ),
                  ),
                  TextSpan(
                    text: 'Política de Privacidade',
                    style: TextStyle(
                      fontSize: 12,
                      color: Styles.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _openPrivacyPolicy(context),
                  ),
                  TextSpan(
                    text: ' do Meudin.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTermsOfUse(BuildContext context) async {
    final uri = Uri.parse('https://phrygian-guan-5b6.notion.site/Termos-de-Uso-Meudin-2d6e00f9b28d809da295d1fa8494eef3');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse('https://phrygian-guan-5b6.notion.site/Pol-tica-de-Privacidade-Meudin-2d6e00f9b28d80af8e51f8232c53254a');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

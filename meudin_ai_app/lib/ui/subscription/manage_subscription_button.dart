import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meudin_ai_app/services/subscription_service.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/ui/joy_text_button.dart';

/// Botão para gerenciar assinatura
/// Abre a página web de billing com SSO
class ManageSubscriptionButton extends StatelessWidget {
  final String? customText;
  final Color? textColor;
  final double? fontSize;

  const ManageSubscriptionButton({
    super.key,
    this.customText,
    this.textColor,
    this.fontSize,
  });

  Future<void> _openBillingPage(BuildContext context) async {
    try {
      // Mostrar loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Obter URL de SSO
      final subscriptionService = SubscriptionService();
      final response = await subscriptionService.getSsoUrl();

      // Fechar loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (response.success && response.data != null) {
        final url = response.data.toString();
        final uri = Uri.parse(url);

        print('[ManageSubscription] URL que será aberta: $url');
        print('[ManageSubscription] URI parseado: ${uri.toString()}');
        print('[ManageSubscription] URI scheme: ${uri.scheme}');
        print('[ManageSubscription] URI host: ${uri.host}');
        print('[ManageSubscription] URI path: ${uri.path}');
        print('[ManageSubscription] URI query: ${uri.query}');

        // Abrir URL no browser externo
        if (await canLaunchUrl(uri)) {
          print('[ManageSubscription] Abrindo URL no browser externo...');
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          print('[ManageSubscription] URL aberta com sucesso!');
        } else {
          print('[ManageSubscription] ERRO: Não foi possível abrir a URL');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Não foi possível abrir a página'),
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.errorMessage ?? 'Erro ao abrir página de assinatura',
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Fechar loading se ainda estiver aberto
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return JoyTextButton(
      text: customText ?? 'Gerenciar assinatura',
      textColor: textColor ?? Styles.primaryColor,
      fontSize: fontSize ?? 14,
      function: () => _openBillingPage(context),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:meudin_ai_app/services/subscription_management_service.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

/// Botão para gerenciar assinatura.
/// iOS → App Store | Android → Google Play | Web/Asaas → billing com SSO.
class ManageSubscriptionButton extends StatelessWidget {
  final String? customText;
  final Color? textColor;
  final double? fontSize;
  final String? subscriptionProvider;

  const ManageSubscriptionButton({
    super.key,
    this.customText,
    this.textColor,
    this.fontSize,
    this.subscriptionProvider,
  });

  Future<void> _openManagement(BuildContext context) async {
    final service = SubscriptionManagementService();
    var loadingShown = false;

    try {
      var provider = subscriptionProvider;

      if (provider == null) {
        final subscription = await service.fetchSubscription();
        provider = subscription?.subscription?.provider;
      }

      final needsSso = service.resolveTarget(provider) ==
          SubscriptionManagementTarget.webBilling;

      if (needsSso && context.mounted) {
        loadingShown = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final result = await service.openManagement(provider: provider);

      if (context.mounted && loadingShown) {
        Navigator.of(context).pop();
        loadingShown = false;
      }

      if (!result.success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.errorMessage ?? 'Erro ao abrir página de assinatura',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted && loadingShown) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
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
      function: () => _openManagement(context),
    );
  }
}

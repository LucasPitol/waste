import 'package:flutter/material.dart';
import 'package:meudin_ai_app/models/user_subscription.dart';
import 'package:meudin_ai_app/ui/subscription/premium_badge.dart';
import 'package:meudin_ai_app/ui/subscription/manage_subscription_button.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

/// Wrapper para funcionalidades premium
/// Mostra badge e botão de upgrade quando o usuário não tem acesso
class PremiumFeatureWrapper extends StatelessWidget {
  final Widget child;
  final UserSubscription? userSubscription;
  final bool requiresPremium; // true = requer Plus ou Pro, false = requer qualquer plano pago
  final String? featureName;
  final Widget? customUpgradeMessage;

  const PremiumFeatureWrapper({
    super.key,
    required this.child,
    this.userSubscription,
    this.requiresPremium = true,
    this.featureName,
    this.customUpgradeMessage,
  });

  bool get _hasAccess {
    if (userSubscription == null) {
      return false; // Se não tem dados, assume que não tem acesso
    }

    if (requiresPremium) {
      // Requer Plus ou Pro
      return userSubscription!.isPremium;
    } else {
      // Requer qualquer plano pago (Plus ou Pro)
      return userSubscription!.isPremium;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasAccess) {
      // Usuário tem acesso, mostra o conteúdo normalmente
      return child;
    }

    // Usuário não tem acesso, mostra mensagem de upgrade
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Styles.whiteColor,
        borderRadius: Styles.sexyBorderRadius,
        border: Border.all(
          color: Styles.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PremiumBadge(),
          const SizedBox(height: 12),
          if (customUpgradeMessage != null)
            customUpgradeMessage!
          else
            Text(
              featureName != null
                  ? '$featureName está disponível para assinantes'
                  : 'Este recurso está disponível para assinantes',
              style: const TextStyle(
                fontSize: 14,
                color: Styles.primaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
          const ManageSubscriptionButton(),
        ],
      ),
    );
  }
}


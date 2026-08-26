import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meudin_ai_app/models/user_subscription.dart';
import 'package:meudin_ai_app/services/subscription_service.dart';
import 'package:meudin_ai_app/services/subscription_state_service.dart';

enum SubscriptionManagementTarget {
  appStore,
  googlePlay,
  webBilling,
}

class SubscriptionManagementResult {
  final bool success;
  final String? errorMessage;

  const SubscriptionManagementResult({
    required this.success,
    this.errorMessage,
  });
}

/// Abre o fluxo correto de gerenciamento conforme provider e plataforma.
class SubscriptionManagementService {
  static const String _androidPackageName = 'com.pitol.meudin';
  static const String _appStoreSubscriptionsUrl =
      'https://apps.apple.com/account/subscriptions';

  final SubscriptionService _subscriptionService = SubscriptionService();
  final SubscriptionStateService _subscriptionStateService =
      SubscriptionStateService();

  SubscriptionManagementTarget resolveTarget(String? provider) {
    switch (provider?.toLowerCase()) {
      case 'apple':
        return SubscriptionManagementTarget.appStore;
      case 'google':
        return SubscriptionManagementTarget.googlePlay;
      case 'asaas':
        return SubscriptionManagementTarget.webBilling;
      default:
        if (kIsWeb) {
          return SubscriptionManagementTarget.webBilling;
        }
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          return SubscriptionManagementTarget.appStore;
        }
        if (defaultTargetPlatform == TargetPlatform.android) {
          return SubscriptionManagementTarget.googlePlay;
        }
        return SubscriptionManagementTarget.webBilling;
    }
  }

  Future<UserSubscription?> fetchSubscription() {
    return _subscriptionStateService.getSubscription();
  }

  Future<SubscriptionManagementResult> openManagement({
    String? provider,
  }) async {
    var resolvedProvider = provider;

    if (resolvedProvider == null) {
      final subscription = await fetchSubscription();
      resolvedProvider = subscription?.subscription?.provider;
    }

    switch (resolveTarget(resolvedProvider)) {
      case SubscriptionManagementTarget.appStore:
        return _openUrl(_appStoreSubscriptionsUrl);
      case SubscriptionManagementTarget.googlePlay:
        return _openUrl(
          'https://play.google.com/store/account/subscriptions?package=$_androidPackageName',
        );
      case SubscriptionManagementTarget.webBilling:
        return _openWebBilling();
    }
  }

  Future<SubscriptionManagementResult> _openUrl(String url) async {
    final uri = Uri.parse(url);

    if (!await canLaunchUrl(uri)) {
      return const SubscriptionManagementResult(
        success: false,
        errorMessage: 'Não foi possível abrir a página de assinatura',
      );
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      return const SubscriptionManagementResult(
        success: false,
        errorMessage: 'Não foi possível abrir a página de assinatura',
      );
    }

    return const SubscriptionManagementResult(success: true);
  }

  Future<SubscriptionManagementResult> _openWebBilling() async {
    final response = await _subscriptionService.getSsoUrl();

    if (!response.success || response.data == null) {
      return SubscriptionManagementResult(
        success: false,
        errorMessage:
            response.errorMessage ?? 'Erro ao abrir página de assinatura',
      );
    }

    return _openUrl(response.data.toString());
  }
}

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:meudin_ai_app/models/user_subscription.dart';
import 'package:meudin_ai_app/services/receipt_storage_service.dart';
import 'package:meudin_ai_app/services/subscription_service.dart';
import 'package:meudin_ai_app/services/subscription_state_service.dart';

/// Controller global do plano do usuário.
/// Revalida ao abrir app via receipt (Apple) ou GET /me/plan e notifica UI sem restart.
class PlanStateController extends GetxController with WidgetsBindingObserver {
  static PlanStateController get to => Get.find<PlanStateController>();

  final SubscriptionService _subscriptionService = SubscriptionService();
  final ReceiptStorageService _receiptStorage = ReceiptStorageService();

  final Rxn<PlanCode> planCode = Rxn<PlanCode>();

  PlanCode get currentPlan => planCode.value ?? PlanCode.free;
  bool get isPremium => currentPlan != PlanCode.free;
  bool get isFree => currentPlan == PlanCode.free;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshPlan();
    }
  }

  /// Revalida plano com backend.
  /// MONO-FE-02: App start → chamar /subscriptions/validate com receipt (Apple)
  /// Fallback: GET /api/subscriptions/me/plan
  Future<void> refreshPlan() async {
    // Apple: validar com receipt persistido (receipt disponível após compra/restore)
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      final receipt = await _receiptStorage.getAppleReceipt();
      if (receipt != null && receipt.isNotEmpty) {
        final plan = await _subscriptionService.validateReceipt(receipt);
        if (plan != null) {
          planCode.value = plan;
          SubscriptionStateService.updateFromPlanCode(plan.value);
          return;
        }
      }
    }

    // Fallback: endpoint leve GET /me/plan
    final plan = await _subscriptionService.getCurrentPlan();
    if (plan != null) {
      planCode.value = plan;
      SubscriptionStateService.updateFromPlanCode(plan.value);
    }
  }

  /// Limpa estado (logout)
  void clearPlan() {
    planCode.value = null;
    SubscriptionStateService.clearCache();
    _receiptStorage.clearAppleReceipt();
  }
}

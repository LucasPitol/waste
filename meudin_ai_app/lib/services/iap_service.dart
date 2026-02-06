import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meudin_ai_app/pages/plans/plans_page_controller.dart';
import 'package:meudin_ai_app/services/subscription_service.dart';
import 'package:meudin_ai_app/services/subscription_state_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';

/// Package name do app (Google Play)
const String _packageName = 'com.pitol.meudin';

/// IDs dos produtos nas lojas
class IapProductIds {
  static const String plus = 'meudin_plus';
  static const String pro = 'meudin_pro';

  static String fromPlanCode(PlanCode code) {
    switch (code) {
      case PlanCode.plus:
        return plus;
      case PlanCode.pro:
        return pro;
      case PlanCode.free:
        throw ArgumentError('Plano gratuito não possui produto IAP');
    }
  }
}

/// Resultado da compra
enum IapPurchaseResult {
  success,
  error,
  canceled,
  pending,
}

/// Serviço de In-App Purchase (Apple / Google)
class IapService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SubscriptionService _subscriptionService = SubscriptionService();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Completer<IapPurchaseResult>? _purchaseCompleter;
  String? _pendingProductId;

  /// Verifica se IAP está disponível
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      return await _iap.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Carrega detalhes dos produtos
  Future<ProductDetailsResponse> loadProducts() async {
    return await _iap.queryProductDetails({
      IapProductIds.plus,
      IapProductIds.pro,
    });
  }

  /// Inicia compra do plano e retorna o resultado
  /// Escuta o purchaseStream e envia receipt/token ao backend em caso de sucesso
  Future<IapPurchaseResult> purchase(PlanDisplay plan) async {
    if (!await isAvailable()) {
      return IapPurchaseResult.error;
    }

    final productId = IapProductIds.fromPlanCode(plan.code);
    final response = await loadProducts();

    if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
      return IapPurchaseResult.error;
    }

    final product = response.productDetails
        .where((p) => p.id == productId)
        .firstOrNull;
    if (product == null) {
      return IapPurchaseResult.error;
    }

    _purchaseCompleter = Completer<IapPurchaseResult>();
    _pendingProductId = productId;

    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (e) {
        _purchaseCompleter?.complete(IapPurchaseResult.error);
      },
    );

    final success = await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );

    if (!success) {
      _subscription?.cancel();
      return IapPurchaseResult.error;
    }

    try {
      return await _purchaseCompleter!.future
          .timeout(const Duration(minutes: 2));
    } on TimeoutException {
      return IapPurchaseResult.error;
    } finally {
      _subscription?.cancel();
      _purchaseCompleter = null;
      _pendingProductId = null;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != _pendingProductId) continue;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _purchaseCompleter?.complete(IapPurchaseResult.pending);
          break;

        case PurchaseStatus.canceled:
          _purchaseCompleter?.complete(IapPurchaseResult.canceled);
          break;

        case PurchaseStatus.error:
          _purchaseCompleter?.complete(IapPurchaseResult.error);
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final validated = await _validateAndComplete(purchase);
          _purchaseCompleter?.complete(
            validated ? IapPurchaseResult.success : IapPurchaseResult.error,
          );
          break;
      }
    }
  }

  /// Envia receipt/token ao backend e completa a compra
  Future<bool> _validateAndComplete(PurchaseDetails purchase) async {
    final user = UserService.currentUser;
    if (user?.token == null || user!.token!.isEmpty) {
      return false;
    }

    final result = await _subscriptionService.validatePurchase(
      purchase: purchase,
      productId: purchase.productID,
      packageName: _packageName,
    );

    if (result) {
      await _iap.completePurchase(purchase);
      SubscriptionStateService.clearCache();
    }

    return result;
  }

  /// Restaura compras (ex: troca de dispositivo)
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}

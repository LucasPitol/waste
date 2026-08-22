import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meudin_ai_app/pages/plans/plans_page_controller.dart';
import 'package:meudin_ai_app/services/receipt_storage_service.dart';
import 'package:meudin_ai_app/services/subscription_service.dart';
import 'package:meudin_ai_app/services/subscription_state_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';

/// Package name do app (Google Play)
const String _packageName = 'com.pitol.meudin';

/// IDs dos produtos nas lojas
class IapProductIds {
  static const String plus = 'meudin_plus_monthly';
  static const String pro = 'meudin_pro_monthly';

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
  final ReceiptStorageService _receiptStorage = ReceiptStorageService();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Completer<IapPurchaseResult>? _purchaseCompleter;
  String? _pendingProductId;

  /// Verifica se IAP está disponível
  Future<bool> isAvailable() async {
    if (kIsWeb) {
      print('[IAP] isAvailable: false (kIsWeb)');
      return false;
    }
    try {
      final available = await _iap.isAvailable();
      print('[IAP] isAvailable: $available');
      return available;
    } catch (e, st) {
      print('[IAP] isAvailable error: $e');
      print('[IAP] stackTrace: $st');
      return false;
    }
  }

  /// Carrega detalhes dos produtos
  Future<ProductDetailsResponse> loadProducts() async {
    print('[IAP] loadProducts: querying ${IapProductIds.plus}, ${IapProductIds.pro}');
    final response = await _iap.queryProductDetails({
      IapProductIds.plus,
      IapProductIds.pro,
    });
    print('[IAP] loadProducts: notFoundIDs=${response.notFoundIDs}, productDetails count=${response.productDetails.length}');
    if (response.productDetails.isNotEmpty) {
      for (final p in response.productDetails) {
        print('[IAP] product: id=${p.id}, title=${p.title}, price=${p.price}');
      }
    }
    return response;
  }

  /// Inicia compra do plano e retorna o resultado
  /// Escuta o purchaseStream e envia receipt/token ao backend em caso de sucesso
  Future<IapPurchaseResult> purchase(PlanDisplay plan) async {
    print('[IAP] purchase: plan=${plan.name}, code=${plan.code}');
    if (!await isAvailable()) {
      print('[IAP] purchase: abortando - IAP não disponível');
      return IapPurchaseResult.error;
    }

    final productId = IapProductIds.fromPlanCode(plan.code);
    print('[IAP] purchase: productId=$productId');
    final response = await loadProducts();

    if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
      print('[IAP] purchase: abortando - produtos não encontrados ou vazios (notFoundIDs=${response.notFoundIDs})');
      return IapPurchaseResult.error;
    }

    final product = response.productDetails
        .where((p) => p.id == productId)
        .firstOrNull;
    if (product == null) {
      print('[IAP] purchase: abortando - produto $productId não está na lista (ids: ${response.productDetails.map((p) => p.id).toList()})');
      return IapPurchaseResult.error;
    }

    _purchaseCompleter = Completer<IapPurchaseResult>();
    _pendingProductId = productId;

    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (e, st) {
        print('[IAP] purchaseStream onError: $e');
        print('[IAP] purchaseStream stackTrace: $st');
        _purchaseCompleter?.complete(IapPurchaseResult.error);
      },
    );

    print('[IAP] purchase: chamando buyNonConsumable para $productId');
    final success = await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );

    if (!success) {
      print('[IAP] purchase: buyNonConsumable retornou false');
      _subscription?.cancel();
      return IapPurchaseResult.error;
    }

    print('[IAP] purchase: aguardando resultado do purchaseStream (timeout 2min)');
    try {
      final result = await _purchaseCompleter!.future
          .timeout(const Duration(minutes: 2));
      print('[IAP] purchase: resultado=$result');
      return result;
    } on TimeoutException {
      print('[IAP] purchase: timeout aguardando purchaseStream');
      return IapPurchaseResult.error;
    } finally {
      _subscription?.cancel();
      _purchaseCompleter = null;
      _pendingProductId = null;
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    print('[IAP] _onPurchaseUpdate: ${purchases.length} purchase(s), _pendingProductId=$_pendingProductId');
    for (final purchase in purchases) {
      print('[IAP] _onPurchaseUpdate: productID=${purchase.productID}, status=${purchase.status}');
      if (purchase.status == PurchaseStatus.error && purchase.error != null) {
        print('[IAP] _onPurchaseUpdate: purchase.error=${purchase.error?.message}, code=${purchase.error?.code}');
      }
      if (purchase.productID != _pendingProductId) continue;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          print('[IAP] _onPurchaseUpdate: completando com pending');
          _purchaseCompleter?.complete(IapPurchaseResult.pending);
          break;

        case PurchaseStatus.canceled:
          print('[IAP] _onPurchaseUpdate: completando com canceled');
          _purchaseCompleter?.complete(IapPurchaseResult.canceled);
          break;

        case PurchaseStatus.error:
          print('[IAP] _onPurchaseUpdate: completando com error');
          _purchaseCompleter?.complete(IapPurchaseResult.error);
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          print('[IAP] _onPurchaseUpdate: status=${purchase.status}, validando com backend...');
          final validated = await _validateAndComplete(purchase);
          print('[IAP] _onPurchaseUpdate: _validateAndComplete=$validated');
          _purchaseCompleter?.complete(
            validated ? IapPurchaseResult.success : IapPurchaseResult.error,
          );
          break;
      }
    }
  }

  /// Envia receipt/token ao backend e completa a compra
  /// Persiste receipt Apple para validação on-demand
  Future<bool> _validateAndComplete(PurchaseDetails purchase) async {
    final user = UserService.currentUser;
    if (user?.token == null || user!.token!.isEmpty) {
      print('[IAP] _validateAndComplete: usuário sem token');
      return false;
    }
    print('[IAP] _validateAndComplete: source=${purchase.verificationData.source}, productID=${purchase.productID}');

    final result = await _subscriptionService.validatePurchase(
      purchase: purchase,
      productId: purchase.productID,
      packageName: _packageName,
    );

    print('[IAP] _validateAndComplete: validatePurchase result=$result');
    if (result) {
      await _iap.completePurchase(purchase);
      SubscriptionStateService.clearCache();
      print('[IAP] _validateAndComplete: completePurchase ok, cache limpo');

      // MONO-FE-01: Persistir receipt Apple para validação on-demand
      if (purchase.verificationData.source == 'app_store') {
        final receipt = purchase.verificationData.serverVerificationData;
        if (receipt.isNotEmpty) {
          await _receiptStorage.saveAppleReceipt(receipt);
        }
      }
    }

    return result;
  }

  /// Restaura compras (ex: troca de dispositivo, reinstalação)
  /// Captura e persiste receipt Apple para validação on-demand
  Future<IapPurchaseResult> restorePurchases() async {
    print('[IAP] restorePurchases: iniciando');
    if (!await isAvailable()) {
      print('[IAP] restorePurchases: IAP não disponível');
      return IapPurchaseResult.error;
    }

    _purchaseCompleter = Completer<IapPurchaseResult>();
    var completed = false;

    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      (purchases) async {
        if (completed) return;
        for (final purchase in purchases) {
          if (purchase.status == PurchaseStatus.restored ||
              purchase.status == PurchaseStatus.purchased) {
            completed = true;
            _purchaseCompleter?.complete(IapPurchaseResult.success);
            _subscription?.cancel();

            // MONO-FE-01: Persistir receipt Apple
            if (purchase.verificationData.source == 'app_store') {
              final receipt = purchase.verificationData.serverVerificationData;
              if (receipt.isNotEmpty) {
                await _receiptStorage.saveAppleReceipt(receipt);
                SubscriptionStateService.clearCache();
              }
            }
            await _iap.completePurchase(purchase);
            return;
          }
        }
      },
      onDone: () {
        if (!completed && !_purchaseCompleter!.isCompleted) {
          _purchaseCompleter?.complete(IapPurchaseResult.canceled);
        }
      },
      onError: (_) {
        if (!_purchaseCompleter!.isCompleted) {
          _purchaseCompleter?.complete(IapPurchaseResult.error);
        }
      },
    );

    print('[IAP] restorePurchases: chamando _iap.restorePurchases()');
    await _iap.restorePurchases();

    try {
      final result = await _purchaseCompleter!.future
          .timeout(const Duration(seconds: 30));
      print('[IAP] restorePurchases: resultado=$result');
      return result;
    } on TimeoutException {
      print('[IAP] restorePurchases: timeout 30s');
      return IapPurchaseResult.error;
    } finally {
      _subscription?.cancel();
      _purchaseCompleter = null;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

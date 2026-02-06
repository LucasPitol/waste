import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/wallet_service.dart';
import 'package:meudin_ai_app/services/subscription_state_service.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class NewWalletPageController extends GetxController {
  final walletNameController = TextEditingController();
  bool loading = false;
  List<String>? errorList;
  late WalletService _walletService;
  late SubscriptionStateService _subscriptionStateService;

  NewWalletPageController() {
    _walletService = WalletService();
    _subscriptionStateService = SubscriptionStateService();
  }

  void createWallet() async {
    List<String> errors = [];
    
    if (walletNameController.text.trim().isEmpty) {
      errors.add('Preencha o nome da carteira');
    } else if (walletNameController.text.trim().length < 3) {
      errors.add('O nome da carteira deve ter pelo menos 3 caracteres');
    }

    if (errors.isNotEmpty) {
      errorList = errors;
      update();
      Future.microtask(() {
        Get.bottomSheet(
          JoyModal.errorBottomSheet(
            context: Get.context!,
            errorList: errors,
            title: 'Revise as informações preenchidas',
          ),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Colors.transparent,
        );
      });
      errorList = null;
      update();
      return;
    }

    // Validar limite de carteiras (client-side)
    final canCreate = await _subscriptionStateService.canCreateWallet();
    if (!canCreate) {
      _showLimitModal(
        message: 'Você atingiu o limite de carteiras do seu plano. Faça upgrade para criar mais carteiras.',
      );
      return;
    }

    loading = true;
    update();

    // API call
    final response = await _walletService.createWallet(
      walletNameController.text.trim(),
    );

    loading = false;
    update();

    if (response.success) {
      // Return the wallet ID from response.data
      final walletId = response.data is String 
          ? response.data as String
          : response.data?.toString();
      Get.back(result: walletId);
    } else {
      final msg = response.errorMessage ?? 'Erro ao criar carteira';
      _showErrorOrLimitModal(
        message: msg,
        isLimitError: _isPlanLimitError(msg),
        title: _isPlanLimitError(msg) ? 'Limite atingido' : 'Erro ao criar carteira',
      );
    }
  }

  bool _isPlanLimitError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('limite') || lower.contains('faça upgrade');
  }

  void _showLimitModal({required String message}) {
    Future.microtask(() {
      Get.bottomSheet(
        JoyModal.limitReachedBottomSheet(
          context: Get.context!,
          message: message,
          title: 'Limite atingido',
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: Colors.transparent,
      );
    });
  }

  void _showErrorOrLimitModal({
    required String message,
    required bool isLimitError,
    required String title,
  }) {
    Future.microtask(() {
      if (isLimitError) {
        Get.bottomSheet(
          JoyModal.limitReachedBottomSheet(
            context: Get.context!,
            message: message,
            title: title,
          ),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Colors.transparent,
        );
      } else {
        Get.bottomSheet(
          JoyModal.errorBottomSheet(
            context: Get.context!,
            errorList: [message],
            title: title,
          ),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Colors.transparent,
        );
      }
    });
  }

  @override
  void onClose() {
    walletNameController.dispose();
    super.onClose();
  }
}

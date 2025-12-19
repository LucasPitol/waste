import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/wallet_service.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class NewWalletPageController extends GetxController {
  final walletNameController = TextEditingController();
  bool loading = false;
  List<String>? errorList;
  late WalletService _walletService;

  NewWalletPageController() {
    _walletService = WalletService();
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
      Future.microtask(() {
        Get.bottomSheet(
          JoyModal.errorBottomSheet(
            context: Get.context!,
            errorList: [response.errorMessage ?? 'Erro ao criar carteira'],
            title: 'Erro ao criar carteira',
          ),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Colors.transparent,
        );
      });
    }
  }

  @override
  void onClose() {
    walletNameController.dispose();
    super.onClose();
  }
}

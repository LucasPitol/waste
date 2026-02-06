import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/wallet_service.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class AddMemberPageController extends GetxController {
  final walletId = Get.arguments as String?;
  final emailController = TextEditingController();
  bool loading = false;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  List<String> validateForm() {
    List<String> errors = [];
    
    if (emailController.text.trim().isEmpty) {
      errors.add('Email é obrigatório');
    } else if (!_isValidEmail(emailController.text.trim())) {
      errors.add('Email inválido');
    }

    return errors;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isPlanLimitError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('limite') || lower.contains('faça upgrade');
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

  Future<void> addMember() async {
    List<String> errors = validateForm();
    
    if (errors.isNotEmpty) {
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
      return;
    }

    if (walletId?.isEmpty ?? true) {
      Future.microtask(() {
        Get.bottomSheet(
          JoyModal.errorBottomSheet(
            context: Get.context!,
            errorList: ['ID da carteira não encontrado'],
            title: 'Erro',
          ),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Colors.transparent,
        );
      });
      return;
    }

    loading = true;
    update();

    try {
      final walletService = WalletService();
      final response = await walletService.addMemberToWallet(
        walletId!,
        emailController.text.trim(),
      );

      loading = false;
      update();

      if (response.success) {
        Get.back(result: true); // Return true to indicate success
      } else {
        final msg = response.errorMessage ?? 'Erro ao adicionar membro';
        _showErrorOrLimitModal(
          message: msg,
          isLimitError: _isPlanLimitError(msg),
          title: _isPlanLimitError(msg) ? 'Limite atingido' : 'Erro ao adicionar membro',
        );
      }
    } catch (e) {
      loading = false;
      update();
      Future.microtask(() {
        Get.bottomSheet(
          JoyModal.errorBottomSheet(
            context: Get.context!,
            errorList: ['Erro ao adicionar membro: $e'],
            title: 'Erro ao adicionar membro',
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
}

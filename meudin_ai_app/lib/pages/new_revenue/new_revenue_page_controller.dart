import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/transaction_service.dart';
import 'package:meudin_ai_app/services/cache_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:meudin_ai_app/utils/centavos_currency_formatter.dart';

import '../../ui/joy_ui.dart';

class NewRevenuePageController extends GetxController {
  final amountController = TextEditingController();
  final reasonController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool loading = false;
  late TransactionService _transactionService;
  late CacheService _cacheService;

  NewRevenuePageController() {
    _transactionService = TransactionService();
    _cacheService = CacheService();
  }

  String get selectedDateString =>
      '${selectedDate.day.toString().padLeft(2, '0')}/'
      '${selectedDate.month.toString().padLeft(2, '0')}/'
      '${selectedDate.year}';

  void pickDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDate = picked;
      update();
    }
  }

  void saveRevenue() async {
    List<String> errors = [];
    if (amountController.text.trim().isEmpty) {
      errors.add('Preencha o valor');
    }
    if (reasonController.text.trim().isEmpty) {
      errors.add('Preencha a descrição');
    }
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
    loading = true;
    update();

    // Extrai o valor numérico do texto formatado
    final valorNumerico = CentavosCurrencyFormatter.parseValue(
      amountController.text.trim(),
    );
    
    // Capitaliza a primeira letra da descrição se necessário
    String descricao = reasonController.text.trim();
    if (descricao.isNotEmpty) {
      descricao = descricao[0].toUpperCase() + descricao.substring(1);
    }
    
    // Converte para string no formato esperado pelo serviço
    final valorString = valorNumerico.toStringAsFixed(2).replaceAll('.', ',');

    // API call
    final response = await _transactionService.saveNewRevenue(
      valorString,
      descricao,
      selectedDate,
    );

    loading = false;
    update();

    if (response.success) {
      // Invalida cache após criar transação
      final user = UserService.currentUser;
      if (user?.currentWalletId != null) {
        await _cacheService.invalidateAllCachesForWallet(user!.currentWalletId!);
      }
      Get.back(result: true);
    } else {
      Future.microtask(() {
        Get.bottomSheet(
          JoyModal.errorBottomSheet(
            context: Get.context!,
            errorList: [response.errorMessage!],
            title: 'Erro ao salvar transação',
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
    amountController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}

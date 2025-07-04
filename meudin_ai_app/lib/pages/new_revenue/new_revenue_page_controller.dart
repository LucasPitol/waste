import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/transaction_service.dart';

import '../../ui/joy_ui.dart';

class NewRevenuePageController extends GetxController {
  final amountController = TextEditingController();
  final reasonController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool loading = false;
  late TransactionService _transactionService;

  NewRevenuePageController() {
    _transactionService = TransactionService();
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
      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: errors,
        title: 'Revise as informações preenchidas',
      );
      return;
    }
    loading = true;
    update();

    // API call
    final response = await _transactionService.saveNewRevenue(
      amountController.text,
      reasonController.text,
      selectedDate,
    );

    loading = false;
    update();

    if (response.success) {
      Get.back(result: true);
    } else {
      JoyModal.bottomSheetError(
        context: Get.context!,
        errorList: [response.errorMessage!],
        title: 'Erro ao salvar transação',
      );
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}

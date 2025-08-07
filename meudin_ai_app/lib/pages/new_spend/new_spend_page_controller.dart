import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/spending_category_service.dart';
import 'package:meudin_ai_app/services/transaction_service.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';


class NewSpendPageController extends GetxController {
  late TransactionService _transactionService;
  final amountController = TextEditingController();
  final reasonController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool loading = false;
  List<String>? errorList;

  String? selectedCategoryId;
  String selectedCategoryName = 'Selecione';

  List<Map<String, String>> categories = [];
  late SpendingCategoryService _spendingCategoryService;

  @override
  void onInit() {
    super.onInit();
    _spendingCategoryService = SpendingCategoryService();
    _transactionService = TransactionService();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final res = await _spendingCategoryService.getSpendingCategories();
    if (res.success && res.data is List) {
      categories = (res.data as List)
          .map<Map<String, String>>((e) => {
                'value': e['value'].toString(),
                'name': e['name'].toString(),
              })
          .toList();
      update();
    }
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

  void pickCategory() async {
    final result = await Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Selecione uma categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...categories.map((cat) => ListTile(
                      title: Text(cat['name']!),
                      onTap: () => Get.back(result: cat),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && result is Map<String, String>) {
      selectedCategoryId = result['value'];
      selectedCategoryName = result['name']!;
      update();
    }
  }

  void saveSpend() async {
    List<String> errors = [];
    if (amountController.text.trim().isEmpty) {
      errors.add('Preencha o valor');
    }
    if (reasonController.text.trim().isEmpty) {
      errors.add('Preencha a descrição');
    }
    if (selectedCategoryId == null) {
      errors.add('Selecione uma categoria');
    }
    if (errors.isNotEmpty) {
      errorList = errors;
      update();
      return;
    } else {
      errorList = null;
    }
    loading = true;
    update();
    try {
      debugPrint('Calling saveNewSpend with: amount=${amountController.text.trim()}, reason=${reasonController.text.trim()}, categoryId=$selectedCategoryId, date=$selectedDate');
      ResponseDto response = await _transactionService.saveNewSpend(
        amountController.text.trim(),
        reasonController.text.trim(),
        selectedCategoryId,
        selectedDate,
      );
      loading = false;
      update();
      if (response.success) {
        Get.back(result: true);
      } else {
        errorList = [response.errorMessage ?? 'Erro ao salvar gasto'];
        update();
      }
    } catch (e, stack) {
      debugPrint('Exception in saveSpend: $e\n$stack');
      loading = false;
      errorList = ['Erro inesperado ao salvar gasto'];
      update();
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}

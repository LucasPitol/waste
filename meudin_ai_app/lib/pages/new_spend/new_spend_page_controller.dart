import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/spending_category_service.dart';
import 'package:meudin_ai_app/services/transaction_service.dart';
import 'package:meudin_ai_app/services/cache_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/models/spending_category.dart';
import 'package:meudin_ai_app/pages/new_spend/widgets/category_picker_bottom_sheet.dart';
import 'package:meudin_ai_app/utils/centavos_currency_formatter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class NewSpendPageController extends GetxController {
  late TransactionService _transactionService;
  late CacheService _cacheService;
  final amountController = TextEditingController();
  final reasonController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool loading = false;
  List<String>? errorList;

  SpendingCategory? selectedCategory;
  String selectedCategoryName = 'Selecione';
  IconData selectedCategoryIcon = FontAwesomeIcons.shapes;

  List<SpendingCategory> categories = [];
  late SpendingCategoryService _spendingCategoryService;

  @override
  void onInit() {
    super.onInit();
    _spendingCategoryService = SpendingCategoryService();
    _transactionService = TransactionService();
    _cacheService = CacheService();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final res = await _spendingCategoryService.getSpendingCategories();
    
    if (res.success && res.data is List) {
      categories = (res.data as List)
          .map<SpendingCategory>((e) => SpendingCategory.fromApi(e))
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
    final result = await Get.bottomSheet<SpendingCategory>(
      CategoryPickerBottomSheet(
        categories: categories,
        selectedCategoryId: selectedCategory?.id,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    
    if (result != null) {
      selectedCategory = result;
      selectedCategoryName = result.name;
      selectedCategoryIcon = result.iconData;
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
    if (selectedCategory == null) {
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
      
      ResponseDto response = await _transactionService.saveNewSpend(
        valorString,
        descricao,
        selectedCategory?.id,
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
        errorList = [response.errorMessage ?? 'Erro ao salvar gasto'];
        update();
      }
    } catch (e) {
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

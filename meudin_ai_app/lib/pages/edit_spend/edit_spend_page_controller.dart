import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/spending_category_service.dart';
import 'package:meudin_ai_app/services/transaction_service.dart';
import 'package:meudin_ai_app/services/cache_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/models/spending_category.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/pages/new_spend/widgets/category_picker_bottom_sheet.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/utils/utils.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditSpendPageController extends GetxController {
  late TransactionService _transactionService;
  late CacheService _cacheService;
  late Transaction _transaction;
  final amountController = TextEditingController();
  final reasonController = TextEditingController();
  DateTime selectedDate;
  bool loading = false;
  bool deleting = false;
  List<String>? errorList;

  SpendingCategory? selectedCategory;
  String selectedCategoryName = 'Selecione';
  IconData selectedCategoryIcon = FontAwesomeIcons.shapes;

  List<SpendingCategory> categories = [];
  late SpendingCategoryService _spendingCategoryService;

  EditSpendPageController(Transaction transaction) : selectedDate = transaction.transactionDate ?? DateTime.now() {
    _transaction = transaction;
    _transactionService = TransactionService();
    _cacheService = CacheService();
    _spendingCategoryService = SpendingCategoryService();
    
    // Pre-fill fields with transaction data
    if (transaction.amount != null) {
      amountController.text = Utils.getAmountFormated(transaction.amount!.abs());
    }
    reasonController.text = transaction.reason ?? '';
    selectedDate = transaction.transactionDate ?? DateTime.now();
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final res = await _spendingCategoryService.getSpendingCategories();
    
    if (res.success && res.data is List) {
      categories = (res.data as List)
          .map<SpendingCategory>((e) => SpendingCategory.fromApi(e))
          .toList();
      
      // Set selected category if exists
      if (_transaction.categoryId != null) {
        selectedCategory = categories.firstWhere(
          (cat) => cat.id == _transaction.categoryId,
          orElse: () => categories.first,
        );
        if (selectedCategory != null) {
          selectedCategoryName = selectedCategory!.name;
          selectedCategoryIcon = selectedCategory!.iconData;
        }
      }
      
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

  void updateSpend() async {
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
      ResponseDto response = await _transactionService.updateTransaction(
        transactionId: _transaction.transactionId!,
        reason: reasonController.text.trim(),
        amount: amountController.text.trim(),
        transactionDate: selectedDate,
        type: 'waste',
        categoryId: selectedCategory?.id,
      );
      
      loading = false;
      update();
      
      if (response.success) {
        // Invalida cache após editar transação
        final user = UserService.currentUser;
        if (user?.currentWalletId != null) {
          await _cacheService.invalidateAllCachesForWallet(user!.currentWalletId!);
        }
        Get.back(result: true);
      } else {
        errorList = [response.errorMessage ?? 'Erro ao atualizar gasto'];
        update();
      }
    } catch (e) {
      loading = false;
      errorList = ['Erro inesperado ao atualizar gasto'];
      update();
    }
  }

  void deleteSpend() async {
    deleting = true;
    update();
    
    try {
      ResponseDto response = await _transactionService.deleteTransaction(
        _transaction.transactionId!,
      );
      
      deleting = false;
      update();
      
      if (response.success) {
        // Invalida cache após deletar transação
        final user = UserService.currentUser;
        if (user?.currentWalletId != null) {
          await _cacheService.invalidateAllCachesForWallet(user!.currentWalletId!);
        }
        Get.back(result: true);
      } else {
        Get.bottomSheet(
          JoyModal.errorBottomSheet(
            context: Get.context!,
            errorList: [response.errorMessage ?? 'Erro ao excluir gasto'],
            title: 'Erro ao excluir gasto',
          ),
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: Colors.transparent,
        );
      }
    } catch (e) {
      deleting = false;
      update();
      Get.bottomSheet(
        JoyModal.errorBottomSheet(
          context: Get.context!,
          errorList: ['Erro inesperado ao excluir gasto'],
          title: 'Erro ao excluir gasto',
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: Colors.transparent,
      );
    }
  }

  void showDeleteConfirmation() {
    final theme = Theme.of(Get.context!);
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark 
              ? theme.colorScheme.surface 
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.triangleExclamation,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Excluir transação?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Essa ação não pode ser desfeita.',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close confirmation modal
                      deleteSpend(); // Execute deletion
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Excluir',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  void onClose() {
    amountController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}

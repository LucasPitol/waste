import 'package:get/get.dart';
import 'package:meudin_ai_app/models/category_expense.dart';
import 'package:meudin_ai_app/models/spending_category.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/services/spending_category_service.dart';
import 'package:meudin_ai_app/services/transaction_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:meudin_ai_app/utils/expense_category_visuals.dart';

class TransactionsPageController extends GetxController {
  List<Transaction> transactions;
  final DateTime startDate;
  late TransactionService _transactionService;
  late SpendingCategoryService _spendingCategoryService;

  List<SpendingCategory> categories = [];
  List<CategoryExpense> chartCategoryExpenses = [];

  TransactionsPageController({
    required this.transactions,
    required this.startDate,
    List<SpendingCategory>? initialCategories,
  }) {
    _transactionService = TransactionService();
    _spendingCategoryService = SpendingCategoryService();
    if (initialCategories != null && initialCategories.isNotEmpty) {
      categories = initialCategories;
    }
    _recalculateChartCategories();
  }

  @override
  void onInit() {
    super.onInit();
    if (categories.isEmpty) {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    final response = await _spendingCategoryService.getSpendingCategories();
    if (response.success && response.data is List) {
      categories = (response.data as List)
          .map<SpendingCategory>((e) => SpendingCategory.fromApi(e))
          .toList();
    }

    _recalculateChartCategories();
    update();
  }

  void _recalculateChartCategories() {
    chartCategoryExpenses = ExpenseCategoryVisuals.calculateChartCategories(
      transactions: transactions,
      categories: categories,
    );
  }

  void openEditTransaction(Transaction transaction, String type) async {
    final result = await Get.toNamed(
      type == 'waste' ? AppRoutes.editSpendRoute : AppRoutes.editRevenueRoute,
      arguments: transaction,
    );

    // If transaction was updated or deleted, refresh the list
    if (result != null && result == true) {
      await refreshTransactions();
      update();
      Get.back(result: true);
    }
  }

  Future<void> refreshTransactions() async {
    final user = UserService.currentUser;
    if (user?.currentWalletId == null) return;

    // Calculate endDate - last day of the month if startDate is first day of month
    DateTime endDate;
    final now = DateTime.now();
    if (startDate.year == now.year && startDate.month == now.month) {
      // Current month - use current day
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    } else {
      // Past month - use last day of that month
      final lastDay = DateTime(startDate.year, startDate.month + 1, 0);
      endDate = DateTime(startDate.year, startDate.month, lastDay.day, 23, 59, 59, 999);
    }

    final response = await _transactionService.getTransactionDtoList(
      user!.currentWalletId!,
      startDate,
      endDate,
    );

    if (response.success && response.data is List) {
      transactions = (response.data as List)
          .map((e) => Transaction.fromJson(e))
          .toList();
      _recalculateChartCategories();
    }
  }
}

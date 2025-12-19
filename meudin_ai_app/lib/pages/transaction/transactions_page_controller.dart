import 'package:get/get.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/services/transaction_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';

class TransactionsPageController extends GetxController {
  List<Transaction> transactions;
  final DateTime startDate;
  late TransactionService _transactionService;

  TransactionsPageController({
    required this.transactions,
    required this.startDate,
  }) {
    _transactionService = TransactionService();
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
    }
  }
}

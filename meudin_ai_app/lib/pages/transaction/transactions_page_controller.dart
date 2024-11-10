import 'package:get/get.dart';
import 'package:meudin_ai_app/models/transaction.dart';

class TransactionsPageController extends GetxController {
  final List<Transaction> transactions;

  TransactionsPageController({
    required this.transactions,
  });
}

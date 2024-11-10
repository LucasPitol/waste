import 'package:meudin_ai_app/pages/transaction/transactions_page_controller.dart';
import 'package:meudin_ai_app/pages/transaction/widgets/widgets.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final arugments = Get.arguments;
    final List<Transaction> transactions = arugments[0];
    final startDate = arugments[1];

    return GetBuilder<TransactionsPageController>(
      init: TransactionsPageController(transactions: transactions),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TransactionPageHeaderWidget(startDate: startDate),
                  const SizedBox(
                    width: double.infinity,
                    height: 10,
                  ),
                  // transactions list
                  transactions.isEmpty
                      ? Container(
                          margin: const EdgeInsets.symmetric(vertical: 40),
                          child: const JoyText('Sem transações nesta data'),
                        )
                      : SizedBox(
                          child: Column(
                            children: transactions.map((e) {
                              return TransactionTile(transaction: e);
                            }).toList(),
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

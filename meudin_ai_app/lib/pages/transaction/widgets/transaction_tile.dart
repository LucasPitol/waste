import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/utils/utils.dart';
import 'package:meudin_ai_app/pages/transaction/transactions_page_controller.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String title = transaction.reason ?? '';
    String date = Utils.formatDateDDMMYY(transaction.transactionDate);
    String amountStr = Utils.getAmountFormated(transaction.amount!.abs());
    bool isPositive = transaction.amount! > 0;
    final transactionType = isPositive ? 'revenue' : 'waste';

    if (isPositive) {
      amountStr = '+$amountStr';
    }

    return InkWell(
      onTap: () {
        final controller = Get.find<TransactionsPageController>();
        controller.openEditTransaction(transaction, transactionType);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JoyText(
                    title,
                  ),
                  JoyText.secundaryText(
                    date,
                  )
                ],
              ),
            ),
            JoyText(
              amountStr,
              textColor: isPositive 
                  ? Colors.green 
                  : (theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

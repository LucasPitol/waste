import 'package:flutter/material.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/utils/utils.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String title = transaction.reason ?? '';
    String date = Utils.formatDateDDMMYY(transaction.transactionDate);
    String amountStr = Utils.getAmountFormated(transaction.amount!);
    bool isPositive = transaction.amount! > 0;

    if (isPositive) {
      amountStr = '+$amountStr';
    }

    return Container(
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
    );
  }
}

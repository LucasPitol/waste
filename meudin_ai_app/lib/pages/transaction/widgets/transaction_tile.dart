import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/models/category_expense.dart';
import 'package:meudin_ai_app/models/spending_category.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/pages/transaction/transactions_page_controller.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/utils/expense_category_visuals.dart';
import 'package:meudin_ai_app/utils/utils.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final List<SpendingCategory> categories;
  final List<CategoryExpense> chartCategoryExpenses;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.categories,
    required this.chartCategoryExpenses,
  });

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

    final leadingVisual = isPositive
        ? ExpenseCategoryVisuals.revenueVisual()
        : ExpenseCategoryVisuals.resolve(
            categoryId: transaction.categoryId,
            chartCategories: chartCategoryExpenses,
            categories: categories,
          );

    return InkWell(
      onTap: () {
        final controller = Get.find<TransactionsPageController>();
        controller.openEditTransaction(transaction, transactionType);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExpenseCategoryIcon(visual: leadingVisual),
            const SizedBox(width: 12),
            Expanded(
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
                  ? ExpenseCategoryVisuals.revenueColor
                  : (theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

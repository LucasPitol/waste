import 'package:intl/intl.dart';
import 'package:meudin_ai_app/models/spending_category.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_vision_controller.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_members_widget.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/utils/constants.dart';
import 'package:meudin_ai_app/utils/utils.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_vision_skeleton.dart';


class WalletVisionWidget extends StatelessWidget {
  final DateTime startDate;
  final double balance;
  final double monthRevenue;
  final double monthSpends;
  final List<Transaction> transactionDtoList;
  final List<Transaction> twoFirstTransactionDtoList;
  final List<SpendingCategory> categories;
  final VoidCallback? onDateTap;
  final bool loading;
  final String currentWalletId;
  final bool isWalletOwner;

  const WalletVisionWidget({
    super.key,
    required this.startDate,
    required this.balance,
    required this.monthRevenue,
    required this.monthSpends,
    required this.transactionDtoList,
    required this.twoFirstTransactionDtoList,
    required this.categories,
    required this.loading,
    required this.currentWalletId,
    required this.isWalletOwner,
    this.onDateTap,
  });

  _buildHomeBox(WalletVisionWidgetController controller, BuildContext context) {
    if (loading) {
      return const WalletVisionSkeleton();
    }
    final theme = Theme.of(context);
    // Normal wallet vision box
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? theme.colorScheme.surface 
            : Styles.whiteColor,
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.3)
                : Styles.greyLighter,
            offset: const Offset(0, 2),
            blurRadius: 2,
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      JoyText.h1(
                        Utils.getAmountFormated(balance),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Balanço do mês',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onDateTap,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.yMMMM(Constants.ptLanguageCode)
                            .format(startDate),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Styles.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Styles.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: double.infinity,
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      JoyText(
                        '+' + Utils.getAmountFormated(monthRevenue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Entrada',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 20,
                  height: 20,
                ),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      JoyText(
                        Utils.getAmountFormated(monthSpends),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Saida',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: double.infinity,
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transações',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)
                        ?? Colors.grey.shade700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    controller.goToSeeAllTransactionsPage(
                      transactions: transactionDtoList,
                      startDate: startDate,
                      categories: categories,
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Ver todas',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Styles.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              child: Column(
                children: twoFirstTransactionDtoList.map((e) {
                  String title = e.reason ?? '';
                  String date = Utils.formatTransactionListDate(e.transactionDate);
                  String amountStr = Utils.getAmountFormated(e.amount!);
                  bool isPositive = e.amount! > 0;

                  if (isPositive) {
                    amountStr = '+' + amountStr;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
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
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildMembersBox(WalletVisionWidgetController controller, BuildContext context) {
    return WalletMembersWidget(
      controller: controller,
      isWalletOwner: isWalletOwner,
      walletId: currentWalletId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<WalletVisionWidgetController>(
      init: WalletVisionWidgetController(),
      builder: (controller) {
        // Update wallet info in controller on every build to ensure currentWalletId is always set
        controller.setWalletInfo(currentWalletId, isWalletOwner);
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: controller.tabs.map(
                    (element) {
                      bool isOptionSelected =
                          element.t1 == controller.selectedTab;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: GestureDetector(
                          onTap: () {
                            controller.selectTab(element.t1, walletId: currentWalletId);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: isOptionSelected
                                ? BoxDecoration(
                                    color: theme.brightness == Brightness.dark 
                                        ? theme.colorScheme.surface 
                                        : Styles.whiteColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.brightness == Brightness.dark 
                                            ? Colors.black.withOpacity(0.3)
                                            : Styles.greyLighter,
                                        offset: const Offset(0, 2),
                                        blurRadius: 2,
                                      ),
                                    ],
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  )
                                : BoxDecoration(
                                    color: theme.scaffoldBackgroundColor),
                            child: Text(
                              element.t2,
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              controller.selectedTab == 0
                  ? _buildHomeBox(controller, context)
                  : _buildMembersBox(controller, context),
            ],
          ),
        );
      },
    );
  }
}

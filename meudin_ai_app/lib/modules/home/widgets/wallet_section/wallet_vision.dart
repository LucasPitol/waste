import 'package:intl/intl.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_vision_controller.dart';
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
  final VoidCallback? onDateTap;

  final bool loading;

  const WalletVisionWidget({
    super.key,
    required this.startDate,
    required this.balance,
    required this.monthRevenue,
    required this.monthSpends,
    required this.transactionDtoList,
    required this.twoFirstTransactionDtoList,
    required this.loading,
    this.onDateTap,
  });

  _buildHomeBox(WalletVisionWidgetController controller) {
    if (loading) {
      return const WalletVisionSkeleton();
    }
    // Normal wallet vision box
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
      decoration: Styles.cardDecoration,
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
                      JoyText.secundaryText(
                        'Balanço do mês',
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onDateTap,
                  child: Text(
                    DateFormat.yMMMM(Constants.ptLanguageCode)
                        .format(startDate),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Styles.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
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
                      JoyText.secundaryText(
                        'Entrada',
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
                      JoyText.secundaryText(
                        'Saida',
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
                JoyText.h1(
                  'Transações',
                ),
                TextButton(
                  onPressed: () {
                    controller.goToSeeAllTransactionsPage(
                      transactions: transactionDtoList,
                      startDate: startDate,
                    );
                  },
                  child: Text(
                    'Ver todas',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Styles.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              child: Column(
                children: twoFirstTransactionDtoList.map((e) {
                  String title = e.reason ?? '';
                  String date = Utils.formatDateDDMMYY(e.transactionDate);
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
                          textColor: isPositive ? Colors.green : Styles.primaryTextColor,
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

  _buildMembersBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletVisionWidgetController>(
      init: WalletVisionWidgetController(),
      builder: (controller) {
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
                            controller.selectTab(element.t1);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: isOptionSelected
                                ? Styles.cardDecoration
                                : BoxDecoration(
                                    color: Styles.whiteConfortColor),
                            child: Text(
                              element.t2,
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              controller.selectedTab == 0
                  ? _buildHomeBox(controller)
                  : _buildMembersBox(),
            ],
          ),
        );
      },
    );
  }
}

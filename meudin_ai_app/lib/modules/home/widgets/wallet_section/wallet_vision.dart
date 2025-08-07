import 'package:intl/intl.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_vision_controller.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/utils/constants.dart';
import 'package:meudin_ai_app/utils/utils.dart';

// Simple shimmer effect for skeleton loading
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  const SkeletonLoader({Key? key, required this.width, required this.height, this.borderRadius}) : super(key: key);

  @override
  _SkeletonLoaderState createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
            gradient: LinearGradient(
              begin: Alignment(-1.0, -0.3),
              end: Alignment(2.0, 0.3),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WalletVisionWidget extends StatelessWidget {
  final DateTime startDate;
  final double balance;
  final double monthRevenue;
  final double monthSpends;
  final List<Transaction> transactionDtoList;
  final List<Transaction> twoFirstTransactionDtoList;

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
  });

  _buildHomeBox(WalletVisionWidgetController controller) {
    // Only show skeleton if loading is true, and only for the home box (Visão tab)
    if (loading) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: double.infinity,
        decoration: Styles.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: 120, height: 24),
                    const SizedBox(height: 8),
                    SkeletonLoader(width: 80, height: 16),
                  ],
                ),
                SkeletonLoader(width: 90, height: 24),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: 60, height: 20),
                    const SizedBox(height: 8),
                    SkeletonLoader(width: 40, height: 14),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: 60, height: 20),
                    const SizedBox(height: 8),
                    SkeletonLoader(width: 40, height: 14),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLoader(width: 100, height: 22),
                SkeletonLoader(width: 60, height: 18),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: List.generate(2, (index) => Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(width: 80, height: 16),
                        const SizedBox(height: 6),
                        SkeletonLoader(width: 60, height: 12),
                      ],
                    ),
                    SkeletonLoader(width: 50, height: 16),
                  ],
                ),
              )),
            ),
          ],
        ),
      );
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
                  onPressed: () {
                    print('_openSwitchDateBottomSheet');
                  },
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

                  if (e.amount! > 0) {
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

import 'package:meudin_ai_app/pages/home_app/widgets/floating_bottom_bar.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_vision.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_vision_skeleton.dart';
import 'package:meudin_ai_app/modules/home/widgets/app_bar/home_app_bar.dart';
import 'package:meudin_ai_app/modules/home/widgets/upgrade_banner/upgrade_banner_widget.dart';
import 'package:meudin_ai_app/modules/home/widgets/expense_category_chart/expense_category_chart_widget.dart';
import 'package:meudin_ai_app/modules/home/widgets/daily_income_expense/daily_income_expense_bar_chart.dart';
import 'package:meudin_ai_app/modules/home/home_module_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../ui/joy_ui.dart';

class HomeModule extends StatelessWidget {
  const HomeModule({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeModuleController>(
      init: HomeModuleController(),
      builder: (controller) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: () async {
                await controller.refreshAll(forceRefresh: true);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      const HomeAppBar(),
                      // plan
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 10),
                                    child: controller.isRefreshing
                                        ? const SkeletonLoader(width: 120, height: 20)
                                        : InkWell(
                                            onTap: controller.isRefreshing
                                                ? null
                                                : () {
                                                    controller.openWalletSelector();
                                                  },
                                            borderRadius: BorderRadius.circular(4),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    controller.currentWallet.name,
                                                    style: TextStyle(
                                                      fontSize: 14.0,
                                                      fontWeight: FontWeight.w500,
                                                      color: Styles.primaryColor,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const AppIcon(
                                                    AppIcons.arrowsUpDown,
                                                    color: Colors.grey,
                                                    size: 14,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                              // JoyText.secundaryText('Plano Free'),
                              const SizedBox(
                                width: double.infinity,
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      WalletVisionWidget(
                        startDate: controller.startDate,
                        balance: controller.monthBalance,
                        monthRevenue: controller.monthRevenue,
                        monthSpends: controller.monthSpends,
                        transactionDtoList: controller.transactionDtoList,
                        twoFirstTransactionDtoList:
                            controller.twoFirstTransactionDtoList,
                        categories: controller.categories,
                        loading: controller.isRefreshing,
                        currentWalletId: controller.currentWallet.id,
                        isWalletOwner: controller.isWalletOwner,
                        onDateTap: controller.openMonthYearPicker,
                      ),
                      // Banner de Upgrade (discreto, abaixo do card principal)
                      // Versão escolhida aleatoriamente em tempo de execução (50% de chance para cada)
                      AnimatedOpacity(
                        opacity: controller.showUpgradeBanner ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: IgnorePointer(
                          ignoring: !controller.showUpgradeBanner,
                          child: UpgradeBannerWidget(
                            version: controller.selectedBannerVersion,
                            onTap: () => Get.toNamed(AppRoutes.plansRoute),
                          ),
                        ),
                      ),
                      // Gráfico de gastos por categoria
                      ExpenseCategoryChartWidget(
                        categoryExpenses: controller.categoryExpenses,
                        startDate: controller.startDate,
                        loading: controller.isRefreshing,
                        transactions: controller.transactionDtoList,
                        categories: controller.categories,
                      ),
                      DailyIncomeExpenseBarChart(
                        transactions: controller.transactionDtoList,
                        startDate: controller.startDate,
                        endDate: controller.endDate,
                        loading: controller.isRefreshing,
                      ),
                      SizedBox(
                        height: FloatingBottomBarLayout.scrollBottomInset(context),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

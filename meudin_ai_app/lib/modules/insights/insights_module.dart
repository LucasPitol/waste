import 'package:meudin_ai_app/modules/insights/insights_module_controller.dart';
import 'package:meudin_ai_app/modules/insights/widgets/kpi_cards_widget.dart';
import 'package:meudin_ai_app/modules/insights/widgets/monthly_average_widget.dart';
import 'package:meudin_ai_app/modules/insights/widgets/comparison_widget.dart';
import 'package:meudin_ai_app/modules/insights/widgets/date_filter_header.dart';
import 'package:meudin_ai_app/modules/insights/widgets/empty_state_widget.dart';
import 'package:meudin_ai_app/modules/home/widgets/expense_category_chart/expense_category_chart_widget.dart';
import 'package:meudin_ai_app/modules/insights/widgets/monthly_income_expense/monthly_income_expense_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class InsightsModule extends StatelessWidget {
  const InsightsModule({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<InsightsModuleController>()) {
      Get.put(InsightsModuleController(), permanent: true);
    }

    return GetBuilder<InsightsModuleController>(
      builder: (controller) {
        final showSkeleton = controller.showSkeleton;
        final showContent =
            controller.hasData || controller.loading || controller.isRefreshing;

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
                      const SizedBox(height: 20),
                      // Título da tela
                      _InsightsAppBar(),
                      const SizedBox(height: 20),
                      // Cabeçalho de filtros
                      DateFilterHeader(
                        startDate: controller.startDate,
                        endDate: controller.endDate,
                        onTap: controller.openDateRangePicker,
                        selectedPreset: controller.activeDatePreset,
                        onPresetSelected: controller.applyDatePreset,
                      ),
                      // KPIs principais
                      KpiCardsWidget(
                        revenue: controller.revenue,
                        spends: controller.spends,
                        balance: controller.balance,
                        loading: showSkeleton,
                      ),
                      if (showContent) ...[
                        ExpenseCategoryChartWidget(
                          categoryExpenses: controller.categoryExpenses,
                          startDate: controller.startDate,
                          loading: showSkeleton,
                          transactions: controller.transactionDtoList,
                          categories: controller.categories,
                          showDate: false,
                        ),
                        MonthlyIncomeExpenseBarChart(
                          transactions: controller.transactionDtoList,
                          startDate: controller.startDate,
                          endDate: controller.endDate,
                          loading: showSkeleton,
                        ),
                        MonthlyAverageWidget(
                          monthlyAverage: controller.monthlyAverageRevenue,
                          loading: showSkeleton,
                          metric: MonthlyAverageMetric.revenue,
                        ),
                        MonthlyAverageWidget(
                          monthlyAverage: controller.monthlyAverageSpends,
                          loading: showSkeleton,
                        ),
                        if (controller.canShowComparison)
                          ComparisonWidget(
                            comparisonPercentage: controller.comparisonPercentage,
                            loading: showSkeleton,
                          ),
                        const SizedBox(height: 20),
                      ],
                      if (!showContent)
                        EmptyStateWidget(
                          onAdjustFilters: controller.openDateRangePicker,
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

/// AppBar simples para a tela de Insights
class _InsightsAppBar extends StatelessWidget {
  const _InsightsAppBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Insights',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
            ),
          ),
          // Espaço vazio para manter alinhamento (pode adicionar botão de perfil aqui no futuro)
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

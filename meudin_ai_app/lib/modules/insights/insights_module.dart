import 'package:meudin_ai_app/modules/insights/insights_module_controller.dart';
import 'package:meudin_ai_app/modules/insights/widgets/kpi_cards_widget.dart';
import 'package:meudin_ai_app/modules/insights/widgets/monthly_average_widget.dart';
import 'package:meudin_ai_app/modules/insights/widgets/comparison_widget.dart';
import 'package:meudin_ai_app/modules/insights/widgets/date_filter_header.dart';
import 'package:meudin_ai_app/modules/insights/widgets/empty_state_widget.dart';
import 'package:meudin_ai_app/modules/home/widgets/expense_category_chart/expense_category_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class InsightsModule extends StatelessWidget {
  const InsightsModule({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InsightsModuleController>(
      init: InsightsModuleController(),
      builder: (controller) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: () async {
                await controller.refreshAll();
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
                        onClearFilters: controller.hasData 
                            ? controller.clearFilters 
                            : null,
                      ),
                      // KPIs principais
                      KpiCardsWidget(
                        revenue: controller.revenue,
                        spends: controller.spends,
                        balance: controller.balance,
                        loading: controller.isRefreshing,
                      ),
                      // Estado vazio ou conteúdo
                      if (controller.hasData || controller.isRefreshing) ...[
                        // Gráfico de gastos por categoria
                        ExpenseCategoryChartWidget(
                          categoryExpenses: controller.categoryExpenses,
                          startDate: controller.startDate,
                          loading: controller.isRefreshing,
                          transactions: controller.transactionDtoList,
                          categories: controller.categories,
                        ),
                        // Média mensal de despesas
                        MonthlyAverageWidget(
                          monthlyAverage: controller.monthlyAverageSpends,
                          loading: controller.isRefreshing,
                        ),
                        // Comparativo simples (se período >= 2 meses)
                        if (controller.canShowComparison)
                          ComparisonWidget(
                            comparisonPercentage: controller.comparisonPercentage,
                            loading: controller.isRefreshing,
                          ),
                        const SizedBox(height: 20),
                      ],
                      if (!controller.hasData && !controller.isRefreshing)
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

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:meudin_ai_app/models/category_expense.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:intl/intl.dart';
import 'package:meudin_ai_app/utils/constants.dart';
import 'package:meudin_ai_app/modules/home/widgets/expense_category_chart/expense_category_chart_skeleton.dart';

class ExpenseCategoryChartWidget extends StatelessWidget {
  final List<CategoryExpense> categoryExpenses;
  final DateTime startDate;
  final bool loading;

  const ExpenseCategoryChartWidget({
    super.key,
    required this.categoryExpenses,
    required this.startDate,
    this.loading = false,
  });

  /// Gera paleta extremamente suave e discreta
  /// Cores quase neutras, apenas o suficiente para diferenciar categorias
  /// Visual silencioso que não compete com elementos principais
  static List<Color> _generateSoftPalette(int count) {
    // Paleta de cores muito suaves, quase neutras
    // Tons de cinza com leve variação, apenas para diferenciar
    final palette = [
      Color(0xFFA0A0B0), // Cinza-azulado suave
      Color(0xFFA8A8A8), // Cinza neutro
      Color(0xFFB0A8A0), // Cinza-bege suave
      Color(0xFFA8B0A8), // Cinza-esverdeado muito suave
      Color(0xFFB0B0B0), // Cinza médio
    ];
    
    return palette.take(count).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show skeleton when loading
    if (loading) {
      return const ExpenseCategoryChartSkeleton();
    }

    // Don't show if no expenses
    if (categoryExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? theme.colorScheme.surface 
            : Styles.whiteColor,
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.shade200.withOpacity(0.5), // Sombra mais sutil
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gastos por categoria',
                style: TextStyle(
                  fontSize: 14.0, // Reduzido de 16 para ser mais discreto
                  fontWeight: FontWeight.w500, // Reduzido de w600
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) 
                      ?? Colors.grey.shade700, // Mais discreto
                ),
              ),
              Text(
                DateFormat.yMMMM(Constants.ptLanguageCode).format(startDate),
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart and Legend
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Donut Chart - Discreto: anel fino, centro dominante, visual silencioso
              SizedBox(
                width: 110,
                height: 110,
                child: PieChart(
                  PieChartData(
                    sections: categoryExpenses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final expense = entry.value;
                      // Paleta extremamente suave
                      final softPalette = _generateSoftPalette(categoryExpenses.length);
                      final color = expense.categoryId == 'others' 
                          ? Colors.grey.shade300 // "Outros" muito discreto
                          : softPalette[index % softPalette.length];
                      
                      return PieChartSectionData(
                        value: expense.amount,
                        title: '',
                        color: color,
                        radius: 8, // ESPESSURA do anel (fino) - não é raio externo!
                        showTitle: false,
                      );
                    }).toList(),
                    centerSpaceRadius: 40, // Centro grande (anel fino)
                    sectionsSpace: 0, // Sem separação (mais discreto)
                    startDegreeOffset: -90, // Começa no topo
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Legend - Refinada: hierarquia visual mais clara
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryExpenses.asMap().entries.map((entry) {
                    final index = entry.key;
                    final expense = entry.value;
                    final softPalette = _generateSoftPalette(categoryExpenses.length);
                    final color = expense.categoryId == 'others' 
                        ? Colors.grey.shade400
                        : softPalette[index % softPalette.length];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              expense.categoryName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500, // Peso médio - categoria é mais importante
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8) 
                                    ?? Colors.grey.shade700, // Mais visível que percentual
                              ),
                            ),
                          ),
                          Text(
                            '${expense.percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11, // Menor que categoria
                              fontWeight: FontWeight.w400, // Peso normal
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4) 
                                  ?? Colors.grey.shade400, // Muito discreto - não destaca
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


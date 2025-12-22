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

  /// Gera paleta com cores específicas definidas
  /// Cores suaves e harmoniosas para visual discreto
  static List<Color> _generateSoftPalette(int count) {
    // Paleta de cores específicas: roxo principal + tons suaves
    final palette = [
      Styles.primaryColor, // Roxo principal (âncora visual)
      const Color(0xFF7C9CBF), // Azul frio suave
      const Color(0xFF94A3B8), // Azul acinzentado
      Styles.primaryColorLight, // Lavanda clara
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
          // Chart and Legend - Mesmo bounding box vertical (sem espaço fantasma)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Donut Chart - Ajustado para compartilhar altura com legenda
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 100, // Diâmetro reduzido para melhor proporção
                      height: 100,
                      child: PieChart(
                        PieChartData(
                          sections: categoryExpenses.asMap().entries.map((entry) {
                            final index = entry.key;
                            final expense = entry.value;
                            // Paleta com cores específicas
                            final softPalette = _generateSoftPalette(categoryExpenses.length);
                            final color = expense.categoryId == 'others' 
                                ? const Color(0xFFD1D5DB) // Cinza neutro para "Outros"
                                : softPalette[index % softPalette.length];
                            
                            return PieChartSectionData(
                              value: expense.amount,
                              title: '',
                              color: color,
                              radius: 7, // Espessura do anel ajustada
                              showTitle: false,
                            );
                          }).toList(),
                          centerSpaceRadius: 36, // Centro ajustado proporcionalmente
                          sectionsSpace: 0, // Sem separação (mais discreto)
                          startDegreeOffset: -90, // Começa no topo
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend - Ajustada para compartilhar altura com gráfico
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categoryExpenses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final expense = entry.value;
                      final softPalette = _generateSoftPalette(categoryExpenses.length);
                      final color = expense.categoryId == 'others' 
                          ? const Color(0xFFD1D5DB) // Cinza neutro para "Outros"
                          : softPalette[index % softPalette.length];
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8), // Espaçamento reduzido
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                expense.categoryName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2, // Line-height ajustado
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8) 
                                      ?? Colors.grey.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${expense.percentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                height: 1.2, // Line-height consistente
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4) 
                                    ?? Colors.grey.shade400,
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
          ),
        ],
      ),
    );
  }
}


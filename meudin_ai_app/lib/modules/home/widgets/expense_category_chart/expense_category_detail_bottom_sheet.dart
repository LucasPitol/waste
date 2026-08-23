import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meudin_ai_app/models/category_expense.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/models/spending_category.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:meudin_ai_app/utils/constants.dart';
import 'package:meudin_ai_app/utils/expense_category_visuals.dart';
import 'package:meudin_ai_app/utils/utils.dart';

class ExpenseCategoryDetailBottomSheet extends StatelessWidget {
  final List<Transaction> transactions;
  final List<SpendingCategory> categories;
  final DateTime startDate;
  final List<CategoryExpense> chartCategoryExpenses; // Para manter cores consistentes
  final bool showDate;

  const ExpenseCategoryDetailBottomSheet({
    super.key,
    required this.transactions,
    required this.categories,
    required this.startDate,
    required this.chartCategoryExpenses,
    this.showDate = true,
  });

  /// Gera paleta com cores específicas definidas (mesma do gráfico)
  static List<Color> _generateSoftPalette(int count) =>
      ExpenseCategoryVisuals.generateSoftPalette(count);

  /// Calcula todas as categorias sem agrupamento de "Outros"
  List<CategoryExpense> _calculateAllCategoryExpenses() {
    // Filtra apenas despesas (valores negativos) com categoria
    final expenses = transactions
        .where((t) => t.amount != null && t.amount! < 0 && t.categoryId != null)
        .toList();

    if (expenses.isEmpty) {
      return [];
    }

    // Agrupa por categoria
    final Map<String, double> totalByCategory = {};
    
    for (var transaction in expenses) {
      final categoryId = transaction.categoryId!;
      final amount = transaction.amount!.abs(); // Converte para positivo
      totalByCategory[categoryId] = (totalByCategory[categoryId] ?? 0.0) + amount;
    }

    // Calcula total
    final double totalAmount = totalByCategory.values.fold(0.0, (sum, value) => sum + value);

    if (totalAmount == 0) {
      return [];
    }

    // Cria mapa de cores do gráfico para manter consistência
    // O gráfico usa a paleta baseada no índice, então precisamos mapear
    // as categorias do gráfico para suas cores na paleta
    final Map<String, Color> colorMap = {};
    final softPalette = _generateSoftPalette(chartCategoryExpenses.length);
    
    // Mapeia as categorias do gráfico (exceto "Outros") para suas cores na paleta
    for (var i = 0; i < chartCategoryExpenses.length; i++) {
      final expense = chartCategoryExpenses[i];
      if (expense.categoryId != 'others') {
        colorMap[expense.categoryId] =
            ExpenseCategoryVisuals.chartColorForIndex(
          index: i,
          categoryId: expense.categoryId,
          chartCategoryCount: chartCategoryExpenses.length,
        );
      }
    }

    // Ordena categorias por valor para atribuir cores consistentes
    final sortedEntries = totalByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Cria lista de CategoryExpense com TODAS as categorias (sem agrupamento)
    final allCategoryExpenses = sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryEntry = entry.value;
      final categoryId = categoryEntry.key;
      final amount = categoryEntry.value;
      final percentage = (amount / totalAmount) * 100;

      // Busca informações da categoria
      final category = categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => SpendingCategory(
          id: categoryId,
          name: 'Outro',
          value: 'other',
          type: 'personal',
          creationDate: DateTime.now(),
          lastUpdate: DateTime.now(),
        ),
      );

      // Usa cor do gráfico se disponível, senão usa cor da categoria ou paleta
      Color categoryColor;
      if (colorMap.containsKey(categoryId)) {
        // Usa a cor exata do gráfico para manter consistência
        categoryColor = colorMap[categoryId]!;
      } else {
        // Para categorias não presentes no gráfico (que estavam em "Outros"),
        // usa a cor da categoria ou uma cor da paleta
        // Prioriza cor da categoria, senão usa paleta
        categoryColor = category.colorData != const Color(0xFFB2BEC3) 
            ? category.colorData 
            : softPalette[index % softPalette.length];
      }

      return CategoryExpense(
        categoryId: categoryId,
        categoryName: category.name,
        categoryColor: categoryColor,
        amount: amount,
        percentage: percentage,
      );
    }).toList();

    // Já está ordenado por valor descendente (sortedEntries)
    return allCategoryExpenses;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allCategoryExpenses = _calculateAllCategoryExpenses();

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? theme.colorScheme.surface 
            : Styles.whiteColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalhamento por categoria',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                      ),
                    ),
                    if (showDate) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMM(Constants.ptLanguageCode).format(startDate),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                              ?? Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Lista de categorias
              Expanded(
                child: allCategoryExpenses.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum gasto encontrado',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                                ?? Colors.grey.shade600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: allCategoryExpenses.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                        itemBuilder: (context, index) {
                          final expense = allCategoryExpenses[index];
                          return _CategoryItem(
                            categoryExpense: expense,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryExpense categoryExpense;

  const _CategoryItem({
    required this.categoryExpense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Indicador de cor
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: categoryExpense.categoryColor,
              shape: BoxShape.circle,
            ),
          ),
          // Nome da categoria
          Expanded(
            child: Text(
              categoryExpense.categoryName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
              ),
            ),
          ),
          // Valor e percentual
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Total gasto (destaque principal)
              Text(
                'R\$ ${Utils.getAmountFormated(categoryExpense.amount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                ),
              ),
              const SizedBox(height: 2),
              // Percentual (contextual, mais leve)
              Text(
                '${categoryExpense.percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5) 
                      ?? Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


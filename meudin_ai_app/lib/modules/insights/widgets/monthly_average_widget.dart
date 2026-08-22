import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:meudin_ai_app/utils/utils.dart';

enum MonthlyAverageMetric { expense, revenue }

extension MonthlyAverageMetricConfig on MonthlyAverageMetric {
  String get title {
    switch (this) {
      case MonthlyAverageMetric.expense:
        return 'Custo médio mensal';
      case MonthlyAverageMetric.revenue:
        return 'Receita média mensal';
    }
  }

  String get infoTitle {
    switch (this) {
      case MonthlyAverageMetric.expense:
        return 'Como calculamos o custo mensal';
      case MonthlyAverageMetric.revenue:
        return 'Como calculamos a receita mensal';
    }
  }

  String get infoDescription {
    switch (this) {
      case MonthlyAverageMetric.expense:
        return 'O custo médio mensal é calculado considerando todas as despesas registradas no período selecionado, divididas pelo número de meses em que existem transações reais (da primeira à última transação).';
      case MonthlyAverageMetric.revenue:
        return 'A receita média mensal é calculada considerando todas as receitas registradas no período selecionado, divididas pelo número de meses em que existem transações reais (da primeira à última transação).';
    }
  }

  IconData get icon {
    switch (this) {
      case MonthlyAverageMetric.expense:
        return Icons.trending_up;
      case MonthlyAverageMetric.revenue:
        return Icons.trending_up;
    }
  }

  Color get iconColor {
    switch (this) {
      case MonthlyAverageMetric.expense:
        return Styles.primaryColor;
      case MonthlyAverageMetric.revenue:
        return Colors.green;
    }
  }

  List<String> get infoBulletPoints {
    switch (this) {
      case MonthlyAverageMetric.expense:
        return [
          'O cálculo respeita a carteira selecionada',
          'Apenas despesas são consideradas (receitas não entram)',
          'Mudanças no período ou na carteira atualizam o valor automaticamente',
        ];
      case MonthlyAverageMetric.revenue:
        return [
          'O cálculo respeita a carteira selecionada',
          'Apenas receitas são consideradas (despesas não entram)',
          'Mudanças no período ou na carteira atualizam o valor automaticamente',
        ];
    }
  }
}

class MonthlyAverageWidget extends StatelessWidget {
  final double? monthlyAverage;
  final bool loading;
  final MonthlyAverageMetric metric;

  const MonthlyAverageWidget({
    super.key,
    this.monthlyAverage,
    this.loading = false,
    this.metric = MonthlyAverageMetric.expense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (loading) {
      return _buildSkeleton(context);
    }

    if (monthlyAverage == null || monthlyAverage == 0) {
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
                : Colors.grey.shade200.withOpacity(0.5),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Icon(
                metric.icon,
                color: metric.iconColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.title,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) 
                            ?? Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Utils.getAmountFormated(monthlyAverage!),
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showInfoBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3) 
                      ?? Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (builder) {
        return Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark 
                ? theme.colorScheme.surface 
                : Styles.whiteColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[theme.brightness == Brightness.dark ? 700 : 300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  metric.infoTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color ?? Styles.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  metric.infoDescription,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: SvgPicture.asset(
                    'assets/analytics.svg',
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Observações importantes:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color ?? Styles.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < metric.infoBulletPoints.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _buildBulletPoint(theme, metric.infoBulletPoints[i]),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBulletPoint(ThemeData theme, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 12),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Styles.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: theme.textTheme.bodyMedium?.color ?? Styles.primaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final skeletonColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface
            : Styles.whiteColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 18,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(4),
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

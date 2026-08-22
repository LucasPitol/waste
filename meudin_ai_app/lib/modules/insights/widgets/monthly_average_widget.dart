import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:meudin_ai_app/utils/utils.dart';

class MonthlyAverageWidget extends StatelessWidget {
  final double? monthlyAverage;
  final bool loading;

  const MonthlyAverageWidget({
    super.key,
    this.monthlyAverage,
    this.loading = false,
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
                Icons.trending_up,
                color: Styles.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custo médio mensal',
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
                // Grey bar at the top
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
                
                // Title
                Text(
                  'Como calculamos o custo mensal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color ?? Styles.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 20),
                // Explanatory text
                Text(
                  'O custo médio mensal é calculado considerando todas as despesas registradas no período selecionado, divididas pelo número de meses em que existem transações reais (da primeira à última transação).',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                // Analytics SVG Image
                Center(
                  child: SvgPicture.asset(
                    'assets/analytics.svg',
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                // Important notes section
                Text(
                  'Observações importantes:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.titleMedium?.color ?? Styles.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBulletPoint(
                  theme,
                  'O cálculo respeita a carteira selecionada',
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  theme,
                  'Apenas despesas são consideradas (receitas não entram)',
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  theme,
                  'Mudanças no período ou na carteira atualizam o valor automaticamente',
                ),
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


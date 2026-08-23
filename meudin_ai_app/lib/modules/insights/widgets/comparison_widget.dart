import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';
import 'package:meudin_ai_app/ui/styles.dart';

class ComparisonWidget extends StatelessWidget {
  final double? comparisonPercentage;
  final bool loading;

  const ComparisonWidget({
    super.key,
    this.comparisonPercentage,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (loading) {
      return _buildSkeleton(context);
    }

    if (comparisonPercentage == null) {
      return const SizedBox.shrink();
    }

    final isIncrease = comparisonPercentage! > 0;
    final color = isIncrease ? Colors.red : Colors.green;
    final icon = isIncrease ? Icons.trending_up : Icons.trending_down;
    final text = isIncrease 
        ? 'Gastos aumentaram ${comparisonPercentage!.toStringAsFixed(0)}% em relação ao período anterior'
        : 'Gastos reduziram ${comparisonPercentage!.abs().toStringAsFixed(0)}% em relação ao período anterior';

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
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8) 
                          ?? Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showInfoBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: AppIcon(
                  AppIcons.circleInfo,
                  size: 18,
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
                  'Como calculamos a comparação',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color ?? Styles.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Comparamos o total de despesas do período selecionado com o período anterior de mesma duração. A variação percentual indica se os gastos aumentaram ou diminuíram.',
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
                _buildBulletPoint(
                  theme,
                  'Exibido apenas quando o período selecionado tem 2 meses ou mais',
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  theme,
                  'O período anterior termina no dia anterior ao início do período atual',
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  theme,
                  'Apenas despesas são consideradas (receitas não entram)',
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                  theme,
                  'O cálculo respeita a carteira selecionada',
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
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

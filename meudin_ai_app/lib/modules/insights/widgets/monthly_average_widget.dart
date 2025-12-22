import 'package:flutter/material.dart';
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
      child: Row(
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
                  'Média mensal de despesas',
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
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
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
              color: Colors.grey.shade300,
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
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


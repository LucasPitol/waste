import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:meudin_ai_app/utils/utils.dart';

class KpiCardsWidget extends StatelessWidget {
  final double revenue;
  final double spends;
  final double balance;
  final bool loading;

  const KpiCardsWidget({
    super.key,
    required this.revenue,
    required this.spends,
    required this.balance,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _buildSkeleton(context);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _KpiCard(
              label: 'Receitas',
              value: revenue,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _KpiCard(
              label: 'Despesas',
              value: spends.abs(),
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _KpiCard(
              label: 'Saldo',
              value: balance.abs(),
              color: balance > 0 
                  ? Colors.green 
                  : balance < 0 
                      ? Colors.red 
                      : Colors.grey,
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
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark 
                    ? theme.colorScheme.surface 
                    : Styles.whiteColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                  ?? Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Utils.getAmountFormated(value),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}


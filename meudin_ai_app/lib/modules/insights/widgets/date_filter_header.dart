import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:meudin_ai_app/utils/constants.dart';

class DateFilterHeader extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onTap;
  final VoidCallback? onClearFilters;
  final bool dateRangeWasAdjusted;
  final DateTime? effectiveStartDate;
  final DateTime? effectiveEndDate;

  const DateFilterHeader({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onTap,
    this.onClearFilters,
    this.dateRangeWasAdjusted = false,
    this.effectiveStartDate,
    this.effectiveEndDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy', Constants.ptLanguageCode);

    final displayStartDate = dateRangeWasAdjusted && effectiveStartDate != null
        ? effectiveStartDate!
        : startDate;
    final displayEndDate = dateRangeWasAdjusted && effectiveEndDate != null
        ? effectiveEndDate!
        : endDate;

    // Verifica se está usando filtros padrão (01/01 do ano corrente até hoje)
    final now = DateTime.now();
    final isDefaultFilter = startDate.year == now.year &&
        startDate.month == 1 &&
        startDate.day == 1 &&
        endDate.year == now.year &&
        endDate.month == now.month &&
        endDate.day == now.day;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: dateRangeWasAdjusted
                            ? Colors.orange.shade700
                            : theme.brightness == Brightness.dark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateRangeWasAdjusted ? 'Período consultado' : 'Período',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)
                                    ?? Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${dateFormat.format(displayStartDate)} - ${dateFormat.format(displayEndDate)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: dateRangeWasAdjusted
                              ? Colors.orange.shade700
                              : Styles.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isDefaultFilter && onClearFilters != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onClearFilters,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Limpar',
                    style: TextStyle(
                      fontSize: 14,
                      color: Styles.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (dateRangeWasAdjusted) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(theme.brightness == Brightness.dark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'A data inicial foi ajustada pelo limite do seu plano. '
                      'Você selecionou ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85)
                            ?? Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

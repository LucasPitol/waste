import 'package:flutter/material.dart';
import 'package:meudin_ai_app/pages/transaction/transactions_page_controller.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';
import 'package:meudin_ai_app/ui/app_typography.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/utils/utils.dart';

class TransactionPageHeaderWidget extends StatelessWidget {
  final DateTime startDate;
  final TransactionListOrder order;
  final ValueChanged<TransactionListOrder> onOrderChanged;

  const TransactionPageHeaderWidget({
    super.key,
    required this.startDate,
    required this.order,
    required this.onOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: AppIcon(
              AppIcons.arrowLeft,
              color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
              size: 20,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transações',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Utils.formatDateMMMdeYYYY(startDate),
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                        ?? Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _OrderDropdown(
            order: order,
            onChanged: onOrderChanged,
          ),
        ],
      ),
    );
  }
}

class _OrderDropdown extends StatelessWidget {
  final TransactionListOrder order;
  final ValueChanged<TransactionListOrder> onChanged;

  const _OrderDropdown({
    required this.order,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final labelColor = theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor;
    final muted = theme.textTheme.bodyMedium?.color ?? Styles.grey;

    return PopupMenuButton<TransactionListOrder>(
      tooltip: 'Ordenar',
      initialValue: order,
      onSelected: onChanged,
      padding: EdgeInsets.zero,
      offset: const Offset(0, 48),
      elevation: 2,
      color: isDark ? theme.colorScheme.surface : Styles.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: Styles.sexyBorderRadius),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(AppIcons.sortDown, size: 16, color: muted),
              const SizedBox(width: 4),
              Text(
                order.label,
                style: AppTypography.textStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
              const SizedBox(width: 4),
              AppIcon(AppIcons.chevronDown, size: 16, color: muted),
            ],
          ),
        ),
      ),
      itemBuilder: (context) {
        return TransactionListOrder.values.map((value) {
          final selected = value == order;
          return PopupMenuItem<TransactionListOrder>(
            value: value,
            height: 48,
            child: Text(
              value.label,
              style: AppTypography.textStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Styles.primaryColor : labelColor,
              ),
            ),
          );
        }).toList();
      },
    );
  }
}

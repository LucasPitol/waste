import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';
import 'package:intl/intl.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:meudin_ai_app/utils/constants.dart';

enum InsightsDatePreset {
  thisYear('Este ano'),
  last6Months('6 meses'),
  last3Months('3 meses');

  const InsightsDatePreset(this.label);
  final String label;
}

class DateFilterHeader extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onTap;
  final InsightsDatePreset? selectedPreset;
  final ValueChanged<InsightsDatePreset>? onPresetSelected;

  const DateFilterHeader({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onTap,
    this.selectedPreset,
    this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.brightness == Brightness.dark
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
                        'Período',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)
                              ?? Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('dd/MM/yyyy', Constants.ptLanguageCode).format(startDate)} - ${DateFormat('dd/MM/yyyy', Constants.ptLanguageCode).format(endDate)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  AppIcon(
                    AppIcons.calendarDots,
                    size: 22,
                    color: Styles.primaryColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: InsightsDatePreset.values.map((preset) {
              final isSelected = selectedPreset == preset;
              return _QuickFilterPill(
                label: preset.label,
                isSelected: isSelected,
                onTap: onPresetSelected != null
                    ? () => onPresetSelected!(preset)
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickFilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _QuickFilterPill({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Styles.primaryColor
                : (isDark ? theme.colorScheme.surface : Styles.whiteColor),
            border: Border.all(
              color: isSelected
                  ? Styles.primaryColor
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (theme.textTheme.bodyMedium?.color ?? Styles.primaryTextColor),
            ),
          ),
        ),
      ),
    );
  }
}

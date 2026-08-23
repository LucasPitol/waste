import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';
import 'package:meudin_ai_app/utils/expense_category_visuals.dart';

class TransactionCategoryBadge extends StatelessWidget {
  static const double badgeSize = 34;
  static const double iconSize = 16;

  final ExpenseCategoryVisual visual;

  const TransactionCategoryBadge({
    super.key,
    required this.visual,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundOpacity = isDark ? 0.18 : 0.14;

    return SizedBox(
      width: badgeSize,
      height: badgeSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: visual.color.withValues(alpha: backgroundOpacity),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: AppIcon(
            visual.icon,
            size: iconSize,
            color: visual.color,
          ),
        ),
      ),
    );
  }
}

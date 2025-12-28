import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

/// Badge para indicar que um recurso é exclusivo para assinantes
class PremiumBadge extends StatelessWidget {
  final String? customText;
  final EdgeInsets? padding;

  const PremiumBadge({
    super.key,
    this.customText,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Styles.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Styles.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: Styles.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            customText ?? 'Disponível para assinantes',
            style: TextStyle(
              fontSize: 11,
              color: Styles.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


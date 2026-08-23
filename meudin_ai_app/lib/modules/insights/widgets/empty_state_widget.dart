import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback? onAdjustFilters;

  const EmptyStateWidget({
    super.key,
    this.onAdjustFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.inbox,
            size: 56,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3) 
                ?? Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma transação encontrada',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Não há transações para o período selecionado',
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) 
                  ?? Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (onAdjustFilters != null) ...[
            const SizedBox(height: 24),
            JoyTextButton(
              function: onAdjustFilters,
              text: 'Ajustar filtros',
            ),
          ],
        ],
      ),
    );
  }
}


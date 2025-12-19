import 'package:flutter/material.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum UpgradeBannerVersion {
  neutral,    // Opção 1 — Neutra (mais segura)
  contextual, // Opção 2 — Contextual (melhor conversão)
}

class UpgradeBannerWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final UpgradeBannerVersion version;

  const UpgradeBannerWidget({
    super.key,
    this.onTap,
    this.version = UpgradeBannerVersion.neutral,
  });

  String get _title {
    switch (version) {
      case UpgradeBannerVersion.neutral:
        return 'Desbloqueie recursos premium no Meudin';
      case UpgradeBannerVersion.contextual:
        return 'Leve sua gestão financeira mais longe';
    }
  }

  String get _subtitle {
    switch (version) {
      case UpgradeBannerVersion.neutral:
        return 'Mais carteiras, membros e histórico ilimitado';
      case UpgradeBannerVersion.contextual:
        return 'Tenha mais carteiras e histórico completo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        // Fundo neutro: lilás com 6-8% de opacidade ou cinza muito claro
        color: theme.brightness == Brightness.dark 
            ? theme.colorScheme.surface.withOpacity(0.3)
            : Styles.primaryColor.withOpacity(0.06),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        // Sombra mínima ou sem sombra
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.1)
                : Colors.black.withOpacity(0.02),
            offset: const Offset(0, 1),
            blurRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ícone pequeno e discreto
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Styles.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.star,
                  size: 12,
                  color: Styles.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Texto em 2 níveis (título + subtítulo)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey.shade600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Seta discreta
            FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 11,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.35) ?? Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

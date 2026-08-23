import 'package:flutter/material.dart';
import 'package:meudin_ai_app/models/ad_banner.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class AdBannerWidget extends StatelessWidget {
  final AdBanner? banner;
  final VoidCallback? onTap;

  const AdBannerWidget({
    super.key,
    this.banner,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Se não houver banner, não renderiza nada
    if (banner == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? theme.colorScheme.surface.withOpacity(0.5)
            : Styles.whiteColor,
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.2)
                : Styles.greyLighter,
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? theme.colorScheme.surface.withOpacity(0.3)
              : Styles.greyLighter,
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap ?? () => _handleBannerTap(context, banner!),
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            // Ícone ou espaço para imagem
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Styles.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: AppIcon(
                  AppIcons.bullhorn,
                  size: 18,
                  color: Styles.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Conteúdo do banner
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner!.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (banner!.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      banner!.description!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    banner!.sponsorLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5) ?? Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // Indicador de ação discreto
            AppIcon(
              AppIcons.chevronRight,
              size: 12,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3) ?? Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBannerTap(BuildContext context, AdBanner banner) async {
    // Prioriza deep link interno
    if (banner.deepLink != null) {
      // TODO: Implementar navegação interna quando necessário
      // Get.toNamed(banner.deepLink);
      return;
    }

    // Fallback para link externo
    if (banner.externalLink != null) {
      final uri = Uri.parse(banner.externalLink!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/pages/plans/plans_page_controller.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class PlansPage extends StatelessWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetBuilder<PlansPageController>(
      init: PlansPageController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.arrowLeft,
                color:
                    theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'Planos',
              style: TextStyle(
                color:
                    theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildHeadline(theme),
                const SizedBox(height: 12),
                _buildSubheadline(theme),
                const SizedBox(height: 32),
                _buildPlusCard(context, theme, controller),
                const SizedBox(height: 16),
                _buildProCard(context, theme, controller),
                const SizedBox(height: 24),
                _buildFreeLink(context, theme),
                const SizedBox(height: 32),
                SvgPicture.asset(
                  'assets/finance.svg',
                  width: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                _buildAppleLegalText(theme),
              ],
            ),
          ),
              if (controller.isPurchasing)
                Container(
                  color: theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Processando compra...'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeadline(ThemeData theme) {
    return Text(
      'Controle total das suas finanças',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
      ),
    );
  }

  Widget _buildSubheadline(ThemeData theme) {
    final secondaryColor =
        theme.textTheme.bodyMedium?.color ?? Colors.grey.shade600;

    return Text(
      'Veja para onde seu dinheiro vai, organize tudo em um só lugar '
      'e tome decisões melhores todo mês.',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondaryColor.withValues(alpha: 0.85),
      ),
    );
  }

  Widget _buildPlusCard(
    BuildContext context,
    ThemeData theme,
    PlansPageController controller,
  ) {
    final plusPlan = PlansPageController.plusPlan;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Styles.primaryColor.withValues(alpha: 0.1),
            Styles.primaryColorLight.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(
          color: Styles.primaryColor.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Styles.primaryColor.withValues(alpha: 0.15),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Badge
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Styles.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Mais popular',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Styles.whiteColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Title + price
          Text(
            'PLUS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color:
                  theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ 7,90 / mês',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Styles.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          // Benefits
          ...PlansPageController.plusBenefits.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: Styles.primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: theme.textTheme.bodyLarge?.color ??
                            Styles.primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // CTA
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: controller.isPurchasing
                  ? null
                  : () => controller.onSubscribe(plusPlan),
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.primaryColor,
                foregroundColor: Styles.whiteColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                controller.isPurchasing ? 'Processando...' : 'Assinar Plus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProCard(
    BuildContext context,
    ThemeData theme,
    PlansPageController controller,
  ) {
    final proPlan = PlansPageController.proPlan;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'PRO',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color:
                  theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ 12,90 / mês',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color:
                  theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          ...PlansPageController.proBenefits.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: Styles.primaryColor.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: theme.textTheme.bodyMedium?.color ??
                            Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: controller.isPurchasing
                  ? null
                  : () => controller.onSubscribe(proPlan),
              style: OutlinedButton.styleFrom(
                foregroundColor: Styles.primaryColor,
                side: const BorderSide(color: Styles.primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                controller.isPurchasing ? 'Processando...' : 'Assinar Pro',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeLink(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: () => Get.back(),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              'Continuar no plano gratuito',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7) ??
                        Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Uso básico com limitações',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5) ??
                        Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleLegalText(ThemeData theme) {
    return Text(
      'Assinatura renovada automaticamente.\n'
      'Cancele a qualquer momento nas configurações da App Store.',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ??
            Colors.grey.shade500,
      ),
      textAlign: TextAlign.center,
    );
  }
}

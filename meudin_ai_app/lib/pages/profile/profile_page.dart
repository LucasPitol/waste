import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/pages/profile/profile_page_controller.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<ProfilePageController>(
      init: ProfilePageController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'Perfil',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: controller.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark 
                              ? theme.colorScheme.surface.withOpacity(0.5)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: Styles.primaryColor.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: FaIcon(
                                  FontAwesomeIcons.solidUser,
                                  size: 32,
                                  color: Styles.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.userName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              controller.userEmail,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Aparência Section
                      _buildSectionHeader(context, theme, 'Aparência'),
                      const SizedBox(height: 12),
                      _buildSettingItem(
                        context,
                        theme,
                        controller,
                        icon: FontAwesomeIcons.palette,
                        title: 'Tema',
                        subtitle: controller.currentThemeName,
                        onTap: () => _showThemeSelector(context, controller),
                        isPrimary: true,
                      ),
                      const SizedBox(height: 32),

                      // Ajuda & Suporte Section
                      _buildSectionHeader(context, theme, 'Ajuda & Suporte'),
                      const SizedBox(height: 12),
                      _buildSettingItem(
                        context,
                        theme,
                        controller,
                        icon: FontAwesomeIcons.circleQuestion,
                        title: 'FAQ',
                        onTap: controller.openFAQ,
                      ),
                      const SizedBox(height: 4),
                      _buildSettingItem(
                        context,
                        theme,
                        controller,
                        icon: FontAwesomeIcons.message,
                        title: 'Enviar sugestão',
                        onTap: controller.sendFeedback,
                      ),
                      const SizedBox(height: 4),
                      _buildSettingItem(
                        context,
                        theme,
                        controller,
                        icon: FontAwesomeIcons.headset,
                        title: 'Falar com suporte',
                        onTap: controller.contactSupport,
                      ),
                      const SizedBox(height: 32),

                      // Sobre Section
                      _buildSectionHeader(context, theme, 'Sobre'),
                      const SizedBox(height: 12),
                      _buildSettingItem(
                        context,
                        theme,
                        controller,
                        icon: FontAwesomeIcons.circleInfo,
                        title: 'Sobre o Meudin',
                        onTap: () => _showAboutBottomSheet(context, controller),
                      ),
                      const SizedBox(height: 4),
                      _buildSettingItem(
                        context,
                        theme,
                        controller,
                        icon: FontAwesomeIcons.fileLines,
                        title: 'Termos de uso',
                        onTap: controller.openTerms,
                      ),
                      const SizedBox(height: 4),
                      _buildSettingItem(
                        context,
                        theme,
                        controller,
                        icon: FontAwesomeIcons.shield,
                        title: 'Política de privacidade',
                        onTap: controller.openPrivacyPolicy,
                      ),
                      const SizedBox(height: 24),
                      
                      // Versão (sem card, texto simples)
                      Center(
                        child: Text(
                          'Versão ${controller.appVersion}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5) ?? Colors.grey.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Logout Button (isolado)
                      _buildLogoutButton(context, theme, controller),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _showThemeSelector(BuildContext context, ProfilePageController controller) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecione o tema',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                ),
              ),
              const SizedBox(height: 20),
              _buildThemeOption(
                context,
                controller,
                ThemeMode.system,
                'Sistema',
                FontAwesomeIcons.desktop,
              ),
              _buildThemeOption(
                context,
                controller,
                ThemeMode.light,
                'Claro',
                FontAwesomeIcons.sun,
              ),
              _buildThemeOption(
                context,
                controller,
                ThemeMode.dark,
                'Escuro',
                FontAwesomeIcons.moon,
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showAboutBottomSheet(BuildContext context, ProfilePageController controller) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.2) ?? Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title
                  Text(
                    'Sobre o Meudin',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'O Meudin é um aplicativo de gestão financeira pessoal e compartilhada, focado em simplicidade e controle real de gastos.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8) ?? Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Com o Meudin, você pode:\n\n• Criar e gerenciar carteiras para diferentes contextos\n• Compartilhar finanças com outras pessoas\n• Registrar receitas e despesas de forma simples\n• Visualizar gráficos e análises por categoria\n• Filtrar transações por período',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.6,
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8) ?? Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ProfilePageController controller,
    ThemeMode themeMode,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isSelected = controller.currentThemeMode == themeMode;
    
    return InkWell(
      onTap: () {
        controller.changeTheme(themeMode);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            FaIcon(
              icon,
              size: 20,
              color: isSelected ? Styles.primaryColor : theme.textTheme.bodyMedium?.color ?? Styles.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Styles.primaryColor : theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                ),
              ),
            ),
            if (isSelected)
              const FaIcon(
                FontAwesomeIcons.check,
                size: 18,
                color: Styles.primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, ThemeData theme, String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Styles.grey,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    ThemeData theme,
    ProfilePageController controller, {
    IconData? icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool showChevron = true,
    bool isPrimary = false,
  }) {
    final isClickable = onTap != null;
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: isClickable ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        constraints: const BoxConstraints(minHeight: 52),
        decoration: BoxDecoration(
          border: isDark 
              ? Border.all(
                  color: theme.colorScheme.surface.withOpacity(0.3),
                  width: 0.5,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: isPrimary ? 36 : 32,
                height: isPrimary ? 36 : 32,
                decoration: BoxDecoration(
                  color: Styles.primaryColor.withOpacity(isPrimary ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    size: isPrimary ? 16 : 14,
                    color: Styles.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showChevron && isClickable)
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 12,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4) ?? Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    ThemeData theme,
    ProfilePageController controller,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: controller.logout,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        constraints: const BoxConstraints(minHeight: 52),
        decoration: BoxDecoration(
          border: isDark
              ? Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 0.5,
                )
              : Border.all(
                  color: Colors.red.withOpacity(0.2),
                  width: 0.5,
                ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.arrowRightFromBracket,
                  size: 14,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Sair',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


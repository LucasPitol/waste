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
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Styles.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: FaIcon(
                                  FontAwesomeIcons.solidUser,
                                  size: 36,
                                  color: Styles.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.userName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.userEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color ?? Styles.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Options
                      Text(
                        'Configurações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Theme Option
                      InkWell(
                        onTap: () => _showThemeSelector(context, controller),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: (theme.textTheme.bodyMedium?.color ?? Styles.grey).withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Styles.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.palette,
                                    size: 18,
                                    color: Styles.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Tema',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                                  ),
                                ),
                              ),
                              Text(
                                controller.currentThemeName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textTheme.bodyMedium?.color ?? Styles.grey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              FaIcon(
                                FontAwesomeIcons.chevronRight,
                                size: 16,
                                color: theme.textTheme.bodyMedium?.color ?? Styles.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Logout Button
                      InkWell(
                        onTap: controller.logout,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: (theme.textTheme.bodyMedium?.color ?? Styles.grey).withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.arrowRightFromBracket,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
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
                              FaIcon(
                                FontAwesomeIcons.chevronRight,
                                size: 16,
                                color: theme.textTheme.bodyMedium?.color ?? Styles.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
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
}


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/pages/profile/profile_page_controller.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfilePageController>(
      init: ProfilePageController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Styles.whiteColor,
          appBar: AppBar(
            backgroundColor: Styles.whiteColor,
            elevation: 0,
            leading: IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: Styles.primaryTextColor,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
            title: const Text(
              'Perfil',
              style: TextStyle(
                color: Styles.primaryTextColor,
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
                          color: Styles.grey.withOpacity(0.1),
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
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Styles.primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.userEmail,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Styles.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Options
                      const Text(
                        'Configurações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Styles.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 16),

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
                              color: Styles.grey.withOpacity(0.2),
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
                              const FaIcon(
                                FontAwesomeIcons.chevronRight,
                                size: 16,
                                color: Styles.grey,
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
}


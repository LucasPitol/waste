import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/services/session_service.dart';
import 'package:meudin_ai_app/services/theme_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfilePageController extends GetxController {
  late String userName;
  late String userEmail;
  late bool loading;
  late ThemeService _themeService;
  String appVersion = '1.0.0'; // Default fallback

  ProfilePageController() {
    loading = false;
    _themeService = Get.find<ThemeService>();
    _loadUserData();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
      update();
    } catch (e) {
      // Se houver erro, mantém o valor padrão
      appVersion = '1.0.0';
    }
  }

  void _loadUserData() {
    final user = UserService.currentUser;
    if (user != null) {
      userName = user.displayName;
      userEmail = user.email;
    } else {
      userName = 'Usuário';
      userEmail = '';
    }
  }

  ThemeMode get currentThemeMode => _themeService.themeMode;
  String get currentThemeName => _themeService.getThemeModeName();

  Future<void> changeTheme(ThemeMode newThemeMode) async {
    await _themeService.setThemeMode(newThemeMode);
    update();
  }

  void openFAQ() {
    Get.toNamed(AppRoutes.faqRoute);
  }

  void sendFeedback() {
    // TODO: Implementar modal/bottom sheet para feedback
    Get.snackbar('Feedback', 'Em breve');
  }

  void contactSupport() {
    // TODO: Implementar contato com suporte
    Get.snackbar('Suporte', 'Em breve');
  }

  void showAbout(BuildContext context) {
    // Implementado na ProfilePage._showAboutBottomSheet
  }

  void openTerms() {
    // TODO: Implementar navegação para termos
    Get.snackbar('Termos', 'Em breve');
  }

  void openPrivacyPolicy() {
    // TODO: Implementar navegação para política
    Get.snackbar('Política', 'Em breve');
  }

  Future<void> logout() async {
    loading = true;
    update();

    try {
      await SessionService.logout();
      Get.offAllNamed(AppRoutes.signInRoute);
    } catch (e) {
      loading = false;
      update();
    }
  }
}


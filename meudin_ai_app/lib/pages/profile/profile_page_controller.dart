import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/services/session_service.dart';
import 'package:meudin_ai_app/services/theme_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';

class ProfilePageController extends GetxController {
  late String userName;
  late String userEmail;
  late bool loading;
  late ThemeService _themeService;

  ProfilePageController() {
    loading = false;
    _themeService = Get.find<ThemeService>();
    _loadUserData();
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


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/local_storage_service.dart';

/// ThemeService - Gerencia o tema do aplicativo (system, light, dark)
class ThemeService extends GetxController {
  final LocalStorageService _localStorage = LocalStorageService();
  
  final Rx<ThemeMode> _themeMode = ThemeMode.dark.obs;
  
  ThemeMode get themeMode => _themeMode.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }

  /// Carrega a preferência de tema salva
  Future<void> _loadThemePreference() async {
    try {
      final preference = await _localStorage.getThemePreference();
      _themeMode.value = _stringToThemeMode(preference);
    } catch (e) {
      _themeMode.value = ThemeMode.dark;
    }
  }

  /// Converte string para ThemeMode
  ThemeMode _stringToThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Converte ThemeMode para string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  /// Atualiza o tema do aplicativo
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    await _localStorage.saveThemePreference(_themeModeToString(mode));
  }

  /// Obtém o nome do tema atual para exibição
  String getThemeModeName() {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
      default:
        return 'Sistema';
    }
  }
}

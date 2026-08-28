import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/local_storage_service.dart';

/// ThemeService - Gerencia o tema do aplicativo (system, light, dark)
class ThemeService extends GetxController {
  final LocalStorageService _localStorage = LocalStorageService();
  
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  
  ThemeMode get themeMode => _themeMode.value;

  /// Carrega a preferência de tema salva (deve ser chamado antes do runApp)
  Future<void> loadSavedPreference() async {
    try {
      final preference = await _localStorage.getThemePreference();
      _themeMode.value = _stringToThemeMode(preference);
    } catch (e) {
      _themeMode.value = ThemeMode.system;
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
        return 'system';
    }
  }

  /// Atualiza o tema do aplicativo
  Future<bool> setThemeMode(ThemeMode mode) async {
    final previousMode = _themeMode.value;
    _themeMode.value = mode;

    final saved = await _localStorage.saveThemePreference(
      _themeModeToString(mode),
    );
    if (!saved) {
      _themeMode.value = previousMode;
    }

    return saved;
  }

  /// Obtém o nome do tema atual para exibição
  String getThemeModeName() {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }
}

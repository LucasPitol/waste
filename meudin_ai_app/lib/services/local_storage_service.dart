import 'dart:convert';

import 'package:meudin_ai_app/models/user.dart';
import 'package:meudin_ai_app/models/wallet.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// LocalStorageService - Armazena TODOS os dados usando flutter_secure_storage
/// para máxima segurança, especialmente importante para dados financeiros.
class LocalStorageService {
  // Storage keys
  static const String _userDataKey = 'secure_user_data';
  static const String _themePreferenceKey = 'theme_preference';
  static const Set<String> _validThemeModes = {'system', 'light', 'dark'};

  // Secure storage configuration
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Store user data securely
  /// Todos os dados são criptografados e armazenados no secure storage
  Future<void> storeUserData(User user) async {
    try {
      // Serialize user to JSON
      final userJson = jsonEncode(user.toJson());
      
      // Store encrypted in secure storage
      await _secureStorage.write(
        key: _userDataKey,
        value: userJson,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieve user data from secure storage
  Future<User?> getUserData() async {
    try {
      // Read encrypted data
      final userJsonStr = await _secureStorage.read(key: _userDataKey);
      
      if (userJsonStr == null || userJsonStr.isEmpty) {
        return null;
      }

      // Parse JSON
      final userJson = jsonDecode(userJsonStr) as Map<String, dynamic>;
      
      // Reconstruct user object
      final user = User();
      user.id = userJson['id'];
      user.displayName = userJson['displayName'];
      user.email = userJson['email'];
      user.token = userJson['token'];
      user.currentWalletId = userJson['currentWalletId'];
      user.creationDate = DateTime.parse(userJson['creationDate']);
      
      // Parse wallets
      final List<dynamic> walletsJson = userJson['walletList'] ?? [];
      user.walletList = walletsJson
          .map((json) => Wallet.fromJson(json as Map<String, dynamic>))
          .toList();

      return user;
    } catch (e) {
      // If parsing fails, clear the bad data and return null
      await deleteUserData();
      return null;
    }
  }

  /// Delete all user data from secure storage
  Future<void> deleteUserData() async {
    try {
      await _secureStorage.delete(key: _userDataKey);
    } catch (e) {
      // Preserva a preferência de tema ao limpar dados corrompidos
      try {
        final themePreference = await _secureStorage.read(key: _themePreferenceKey);
        await _secureStorage.deleteAll();
        if (themePreference != null &&
            _validThemeModes.contains(themePreference)) {
          await _secureStorage.write(
            key: _themePreferenceKey,
            value: themePreference,
          );
        }
      } catch (e) {
        // Silent error handling
      }
    }
  }

  /// Check if user is logged in (has valid session)
  Future<bool> hasValidSession() async {
    try {
      final userJsonStr = await _secureStorage.read(key: _userDataKey);
      
      if (userJsonStr == null || userJsonStr.isEmpty) {
        return false;
      }

      // Validate that we can parse the data and has token
      final userJson = jsonDecode(userJsonStr) as Map<String, dynamic>;
      final token = userJson['token'] as String?;
      final userId = userJson['id'] as String?;
      
      return token != null && token.isNotEmpty && userId != null;
    } catch (e) {
      return false;
    }
  }

  /// Get stored token
  Future<String?> getToken() async {
    try {
      final userJsonStr = await _secureStorage.read(key: _userDataKey);
      
      if (userJsonStr == null || userJsonStr.isEmpty) {
        return null;
      }

      final userJson = jsonDecode(userJsonStr) as Map<String, dynamic>;
      return userJson['token'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Update current wallet ID
  Future<void> updateCurrentWalletId(String walletId) async {
    try {
      // Read current data
      final user = await getUserData();
      
      if (user != null) {
        // Update wallet ID
        user.currentWalletId = walletId;
        
        // Save back
        await storeUserData(user);
      }
    } catch (e) {
      // Silent error handling
    }
  }

  /// Update user's wallet list
  Future<void> updateWalletList(List<Wallet> wallets) async {
    try {
      // Read current data
      final user = await getUserData();
      
      if (user != null) {
        // Update wallet list
        user.walletList = wallets;
        
        // Save back
        await storeUserData(user);
      }
    } catch (e) {
      // Silent error handling
    }
  }

  /// Save theme preference (system, light, dark)
  Future<bool> saveThemePreference(String themeMode) async {
    if (!_validThemeModes.contains(themeMode)) {
      return false;
    }

    try {
      await _secureStorage.write(
        key: _themePreferenceKey,
        value: themeMode,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get theme preference (default: 'system')
  Future<String> getThemePreference() async {
    try {
      final themeMode = await _secureStorage.read(key: _themePreferenceKey);
      if (themeMode == null) {
        return 'system';
      }
      return _validThemeModes.contains(themeMode) ? themeMode : 'system';
    } catch (e) {
      return 'system';
    }
  }
}
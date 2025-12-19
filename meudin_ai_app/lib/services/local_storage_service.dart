import 'dart:convert';

import 'package:meudin_ai_app/models/user.dart';
import 'package:meudin_ai_app/models/wallet.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// LocalStorageService - Armazena TODOS os dados usando flutter_secure_storage
/// para máxima segurança, especialmente importante para dados financeiros.
class LocalStorageService {
  // Storage keys
  static const String _userDataKey = 'secure_user_data';

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
      print('Error storing user data: $e');
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
      print('Error retrieving user data: $e');
      await deleteUserData();
      return null;
    }
  }

  /// Delete all user data from secure storage
  Future<void> deleteUserData() async {
    try {
      await _secureStorage.delete(key: _userDataKey);
    } catch (e) {
      print('Error deleting user data: $e');
      // Force delete all if specific key fails
      try {
        await _secureStorage.deleteAll();
      } catch (e) {
        print('Error deleting all secure storage: $e');
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
      print('Error updating current wallet ID: $e');
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
      print('Error updating wallet list: $e');
    }
  }
}
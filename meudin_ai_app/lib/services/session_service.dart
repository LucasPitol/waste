import 'package:meudin_ai_app/services/local_storage_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';

class SessionService {
  static final LocalStorageService _storage = LocalStorageService();

  /// Try to restore user session from local storage
  static Future<bool> tryAutoLogin() async {
    try {
      // Check if we have a valid session
      final hasSession = await _storage.hasValidSession();
      if (!hasSession) {
        return false;
      }

      // Try to retrieve user data
      final user = await _storage.getUserData();
      
      if (user != null && user.token != null && user.token!.isNotEmpty) {
        // Restore user session
        UserService.currentUser = user;
        return true;
      }
      
      return false;
    } catch (e) {
      // If anything fails, clear session and return false
      await logout();
      return false;
    }
  }

  /// Save user session
  static Future<void> saveSession() async {
    try {
      final user = UserService.currentUser;
      if (user != null) {
        await _storage.storeUserData(user);
      }
    } catch (e) {
      // Silent error handling
    }
  }

  /// Logout and clear all session data
  static Future<void> logout() async {
    try {
      // Call API logout endpoint to invalidate session
      final userService = UserService();
      await userService.logout();
      
      // Data is already cleared in UserService.logout()
      // but ensure it's cleared here too
      await _storage.deleteUserData();
      UserService.currentUser = null;
    } catch (e) {
      // Force clear even if there's an error
      await _storage.deleteUserData();
      UserService.currentUser = null;
    }
  }

  /// Get current auth token
  static Future<String?> getToken() async {
    try {
      return await _storage.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Update current wallet ID in storage
  static Future<void> updateCurrentWalletId(String walletId) async {
    try {
      await _storage.updateCurrentWalletId(walletId);
      if (UserService.currentUser != null) {
        UserService.currentUser!.currentWalletId = walletId;
      }
    } catch (e) {
      // Silent error handling
    }
  }
}

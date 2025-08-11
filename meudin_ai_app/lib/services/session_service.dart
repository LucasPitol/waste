import 'package:meudin_ai_app/services/local_storage_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';

class SessionService {
  static Future<bool> tryAutoLogin() async {
    final user = await LocalStorageService().getUserData();
    if (user != null && (user.token != null && user.token!.isNotEmpty)) {
      UserService.currentUser = user;
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    await LocalStorageService().deleteUserData();
    UserService.currentUser = null;
  }
}

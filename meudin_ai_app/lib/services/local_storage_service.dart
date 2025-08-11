import 'dart:convert';

import 'package:meudin_ai_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final String _userLocalKey = 'user';

  storeUserData(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String userJsonString = jsonEncode(user.toJson());

    await prefs.setString(_userLocalKey, userJsonString);
  }

  Future<User?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userStr = prefs.getString(_userLocalKey);

    if (userStr != null) {
      try {
        return User.fromJson(jsonDecode(userStr));
      } catch (e) {
        // If parsing fails, clear the bad data and return null
        await prefs.remove(_userLocalKey);
        return null;
      }
    }
    return null;
  }

  Future<void> deleteUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userLocalKey);
  }
}
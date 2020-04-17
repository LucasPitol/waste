import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/login_form.dart';
import 'package:waste_app/models/user_dto.dart';

class AuthService {
  final dbReference = Firestore.instance;

  static UserDto currentUser = new UserDto();

  static void changeLanguage(String language) {
    AuthService.currentUser.language = language;
  } 

  Future<UserDto> login(LoginForm form) async {
    UserDto userDtoTemp;
  }
}
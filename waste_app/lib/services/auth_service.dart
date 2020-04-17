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

    String userMail = form.userMail.text;
    String password = form.password.text;

    await dbReference
        .collection('user')
        .where('email', isEqualTo: userMail)
        .where('password', isEqualTo: password)
        .getDocuments()
        .then((QuerySnapshot snapShot) async {
      var userRef = snapShot.documents.first;

      var user = userRef.data;

      var uid = userRef.documentID;

      if (user != null) {
        AuthService.currentUser.email = user['email'];
        AuthService.currentUser.name = user['name'];
        AuthService.currentUser.language = user['language'];
        AuthService.currentUser.theme = user['theme'];
        AuthService.currentUser.uid = uid;
      }

      return user;
    }).catchError((onError) {
      print(onError);
    });

    return userDtoTemp;
  }
}

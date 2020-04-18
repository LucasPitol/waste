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
      print(user);

      var uid = userRef.documentID;

      if (user != null) {
        Map<String, dynamic> preferences = user['preferences'];
        userDtoTemp.email = user['email'];
        userDtoTemp.name = user['name'];
        userDtoTemp.language = preferences['language'];
        userDtoTemp.theme = preferences['theme'];
        userDtoTemp.uid = uid;
      }

      AuthService.currentUser = userDtoTemp;

      return userDtoTemp;
    }).catchError((onError) {
      print(onError);
      return userDtoTemp;
    });

    return userDtoTemp;
  }
}

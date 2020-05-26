import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_app/models/login_form.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/utils/constants.dart';

class AuthService {
  final dbReference = Firestore.instance;

  static UserDto currentUser = new UserDto();

  static void changeLanguage(String language) {
    AuthService.currentUser.language = language;
  }

  static isAuthenticated() {
    return currentUser != null &&
        currentUser.name != null &&
        currentUser.name.isNotEmpty;
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
        userDtoTemp = UserDto();
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

  Future<String> createNewUser(
      String name, String userMail, String password) async {
    String errorMsg;

    await dbReference
        .collection('user')
        .where('email', isEqualTo: userMail)
        .getDocuments()
        .then((snapShot) async {
      var userRef =
          snapShot.documents.isEmpty ? null : snapShot.documents.first;

      if (userRef != null) {
        errorMsg = Constants.getUserAlreadyExistsMsg(currentUser.language);
        return errorMsg;
      }

      Map<String, dynamic> preferencesMap = {
        'language': currentUser.language,
        'theme': 'light'
      };

      await dbReference.collection('user').add({
        'name': name,
        'email': userMail,
        'password': password,
        'preferences': preferencesMap,
        'creationDate': Timestamp.fromDate(DateTime.now())
      }).then((onValue) {
        currentUser.email = userMail;
        currentUser.name = name;
        
        return null;
      }).catchError((onError) {
        print(onError);
        errorMsg = 'Erro desconhecido';
        return errorMsg;
      });
    }).catchError((onError) {
      print(onError);
      errorMsg = 'Erro desconhecido';

      return errorMsg;
    });
    return errorMsg;
  }
}

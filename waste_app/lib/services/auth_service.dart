import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/login_form.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/models/wallet.dart';
import 'wallet_service.dart';

class AuthService {
  final dbReference = Firestore.instance;

  static UserDto currentUser = new UserDto();

  WalletService walletService;

  AuthService() {
    this.walletService = WalletService();
  }

  static void changeLanguage(String language) {
    AuthService.currentUser.language = language;
  }

  static isAuthenticated() {
    return currentUser != null &&
        currentUser.name != null &&
        currentUser.name.isNotEmpty;
  }

  Future<String> encryptString(String input) async {
    // final cryptor = new PlatformStringCryptor();

    // String salt = await cryptor.generateSalt();
    // String key = await cryptor.generateKeyFromPassword(input, salt);

    return input;
  }

  Future<UserDto> login(LoginForm form) async {
    UserDto userDtoTemp;

    String userMail = form.userMail.text;
    String password = form.password.text;
    String passwordEncrypt = await this.encryptString(password);

    await dbReference
        .collection('user')
        .where('email', isEqualTo: userMail)
        .where('password', isEqualTo: passwordEncrypt)
        .getDocuments()
        .then((QuerySnapshot snapShot) async {
      var userRef = snapShot.documents.first;

      var user = userRef.data;

      var uid = userRef.documentID;

      List<Wallet> wallets = await this.walletService.getWalletsByUserId(uid);

      AuthService.currentUser.email = user['email'];
      AuthService.currentUser.name = user['displayName'];
      AuthService.currentUser.uid = uid;
      AuthService.currentUser.walletList = wallets;
      AuthService.currentUser.currentWalletId = wallets[0].id;

      userDtoTemp = AuthService.currentUser;

      this.updateUserData(uid);

      await this._setUserIdToLocalStorage(uid);

      return userDtoTemp;
    }).catchError((onError) {
      print(onError);
      return userDtoTemp;
    });

    return userDtoTemp;
  }

  void updateUserData(String uid) {
    DocumentReference docRef = dbReference.collection('user').document(uid);

    docRef.setData({'lastAccess': Timestamp.fromDate(DateTime.now())},
        merge: true);
  }

  Future<bool> loginByUid(String uid) async {
    DocumentReference docRef = dbReference.collection('user').document(uid);

    await docRef.setData({
      'uid': uid,
      'lastAccess': Timestamp.fromDate(DateTime.now()),
    }, merge: true);

    await this._setUserIdToLocalStorage(uid);

    List<Wallet> wallets = await this.walletService.getWalletsByUserId(uid);

    await docRef.get().then((onValue) {
      var user = onValue.data;

      AuthService.currentUser.email = user['email'];
      AuthService.currentUser.name = user['displayName'];
      AuthService.currentUser.uid = uid;
      AuthService.currentUser.walletList = wallets;
      AuthService.currentUser.currentWalletId = wallets[0].id;
    });
  }

  void signOut() {
    this._clearLocalStorage();
    AuthService.currentUser = UserDto();
  }

  Future<void> _setUserIdToLocalStorage(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setString('uid', uid);
  }

  Future<void> _clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<String> createNewUser(
      String name, String userMail, String password) async {
    String errorMsg;

    String passwordEncrypt = await this.encryptString(password);

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

      await dbReference.collection('user').add({
        'displayName': name,
        'email': userMail,
        'password': passwordEncrypt,
        'creationDate': Timestamp.fromDate(DateTime.now())
      }).then((onValue) async {
        String uid = await onValue.documentID;

        await this._setUserIdToLocalStorage(uid);

        AuthService.currentUser.name = name;
        AuthService.currentUser.email = userMail;
        AuthService.currentUser.uid = uid;

        List<Wallet> wallets = await this.walletService.getWalletsByUserId(uid);

        AuthService.currentUser.walletList = wallets;
        AuthService.currentUser.currentWalletId = wallets[0].id;

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

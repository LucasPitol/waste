import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_app/models/forms/login_form.dart';
import 'package:waste_app/models/dtos/member-dto.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/smart_error.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:flutter/material.dart';
import 'smart_error_service.dart';
import 'wallet_service.dart';
import 'dart:convert';

class AuthService {
  final dbReference = FirebaseFirestore.instance;
  SmartErrorService smartErrorService = SmartErrorService();

  static UserDto currentUser = new UserDto();

  WalletService walletService;

  AuthService() {
    this.walletService = WalletService();
  }

  void changeLanguage(String newLanguage) {
    currentUser.language = newLanguage;

    String uid = currentUser.uid;

    DocumentReference docRef = dbReference.collection('user').doc(uid);

    docRef.set({
      'language': newLanguage,
      'lastUpdate': Timestamp.fromDate(DateTime.now())
    }, SetOptions(merge: true));
  }

  Future<bool> changePassword(String newPassword, String userId) async {
    DocumentReference docRef = dbReference.collection('user').doc(userId);

    var passwordEncr = await this.encryptString(newPassword);

    await docRef.set({
      'password': passwordEncr,
      'lastUpdate': Timestamp.fromDate(DateTime.now())
    }, SetOptions(merge: true));

    return true;
  }

  static isAuthenticated() {
    return currentUser != null &&
        currentUser.name != null &&
        currentUser.name.isNotEmpty;
  }

  Future<String> encryptString(String input) async {
    final encrypted = base64Encode(utf8.encode(input));

    return encrypted;
  }

  Future<String> dencryptString(String input) async {
    final decryptedByte = base64Decode(input);

    final decrypted = utf8.decode(decryptedByte);

    return decrypted;
  }

  Future<UserDto> login(LoginForm form) async {
    UserDto userDtoTemp;

    String userMail = form.userMail.text;
    String password = form.password.text;

    await dbReference
        .collection('user')
        .where('email', isEqualTo: userMail)
        .get()
        .then((QuerySnapshot snapShot) async {
      var userRef = snapShot.docs.first;

      Map<String, dynamic> user = userRef.data();

      String passwordEncrypt = user['password'];

      String passwordDencrypt = await this.dencryptString(passwordEncrypt);

      if (passwordDencrypt != password) {
        return userDtoTemp;
      }

      var uid = userRef.id;

      List<Wallet> wallets = await this.walletService.getWalletsByUserId(uid);

      AuthService.currentUser.email = user['email'];
      AuthService.currentUser.name = user['displayName'];
      AuthService.currentUser.uid = uid;
      AuthService.currentUser.language = user['language'];
      AuthService.currentUser.walletList = wallets;
      AuthService.currentUser.currentWalletId = wallets[0].id;

      userDtoTemp = AuthService.currentUser;

      this.updateUserData(uid);

      await this._setUserIdToLocalStorage(uid);

      return userDtoTemp;
    }).catchError((onError) {
      print('erro login');
      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Login';
      errorDto.userId = 'email: ' + userMail;

      this.smartErrorService.saveError(errorDto);

      return userDtoTemp;
    });

    return userDtoTemp;
  }

  void updateUserData(String uid) {
    DocumentReference docRef = dbReference.collection('user').doc(uid);

    docRef.set({'lastAccess': Timestamp.fromDate(DateTime.now()), 'uid': uid},
        SetOptions(merge: true));
  }

  Future<bool> loginByUid(String uid) async {
    DocumentReference docRef = dbReference.collection('user').doc(uid);

    await docRef.get().then((onValue) async {
      print(onValue.exists);
      if (onValue.exists) {
        await docRef.set({
          'uid': uid,
          'lastAccess': Timestamp.fromDate(DateTime.now()),
        }, SetOptions(merge: true));

        await this._setUserIdToLocalStorage(uid);

        List<Wallet> wallets = await this.walletService.getWalletsByUserId(uid);

        Map<String, dynamic> user = onValue.data();

        AuthService.currentUser.email = user['email'];
        AuthService.currentUser.name = user['displayName'];
        AuthService.currentUser.uid = uid;
        AuthService.currentUser.language = user['language'];
        AuthService.currentUser.walletList = wallets;
        AuthService.currentUser.currentWalletId = wallets[0].id;
      } else {
        this._clearLocalStorage();
      }
    }).catchError((onError) {
      print(onError);
      this._clearLocalStorage();

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Auto login';
      errorDto.userId = uid;

      this.smartErrorService.saveError(errorDto);
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
        .get()
        .then((snapShot) async {
      var userRef =
          snapShot.docs.isEmpty ? null : snapShot.docs.first;

      if (userRef != null) {
        errorMsg = Constants.getUserAlreadyExistsMsg(currentUser.language);
        return errorMsg;
      }

      await dbReference.collection('user').add({
        'displayName': name,
        'email': userMail,
        'password': passwordEncrypt,
        'language': 'auto',
        'creationDate': Timestamp.fromDate(DateTime.now())
      }).then((onValue) async {
        String uid = onValue.id;

        this.updateUserData(uid);

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

        SmartError errorDto = SmartError();
        errorDto.errorLog = onError.toString();
        errorDto.feature = 'Create new user';
        errorDto.userId = 'email: ' + userMail;

        this.smartErrorService.saveError(errorDto);

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

  Future<void> userExists(BuildContext context) async {
    String uid = currentUser.uid;

    if (uid == null || uid.isEmpty) {
      this.signOut();
      Phoenix.rebirth(context);
    }

    DocumentReference docRef = dbReference.collection('user').doc(uid);

    await docRef.get().then((onValue) async {
      if (!onValue.exists) {
        this.signOut();
        Phoenix.rebirth(context);
      }
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Check if user exists';
      errorDto.userId = uid;

      this.smartErrorService.saveError(errorDto);

      this.signOut();
      Phoenix.rebirth(context);
    });
  }

  Future<MemberDto> getMemberByEmail(String email) async {
    MemberDto member;

    await this
        .dbReference
        .collection('user')
        .where('email', isEqualTo: email)
        .get()
        .then((value) {
      var user = value.docs.first;

      if (user != null) {
        String userId = user.id;
        Map<String, dynamic> obj = user.data();

        member = MemberDto();

        member.email = email;
        member.id = userId;
        member.name = obj['displayName'];

        return member;
      }
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Get member by email';
      errorDto.userId = currentUser.uid;

      this.smartErrorService.saveError(errorDto);
      return member;
    });

    return member;
  }

  Future<void> sendResetPasswordEmail(String userMail) async {
    await this
        .dbReference
        .collection('user')
        .where('email', isEqualTo: userMail)
        .get()
        .then((onValue) {
      var userSS = onValue.docs.first;

      if (userSS != null) {}
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Send reset password email';
      errorDto.userId = 'email: ' + userMail;

      this.smartErrorService.saveError(errorDto);
    });
  }
}

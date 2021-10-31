import 'dart:convert';

import 'package:meudin_app/db/user_dao.dart';
import 'package:meudin_app/models/dtos/response_dto.dart';
import 'package:meudin_app/models/forms/login_form.dart';
import 'package:meudin_app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static User? currentUser;

  late UserDao _userDao;

  UserService() {
    _userDao = UserDao();
  }

  static isAuthenticated() {
    return currentUser != null &&
        currentUser!.id != null &&
        currentUser!.id.isNotEmpty;
  }

  Future<ResponseDto> logIn(LoginForm form) async {
    ResponseDto res = ResponseDto();

    String userMail = form.userMail.text;
    String password = form.password.text;

    String passwordEncrypt = await _encryptString(password);

    User? user = await _userDao.auth(userMail, passwordEncrypt);

    if (user != null) {
      currentUser = user;

      String userId = user.id;

      ResponseDto walletRes =
          ResponseDto(); //await _walletService.getWalletsByUserId(userId);
      walletRes.success = true;
      walletRes.data = [];

      if (walletRes.success) {
        currentUser!.walletList = walletRes.data;
        //currentUser!.currentWalletId = currentUser!.walletList.first.id;

        await _setUserIdToLocalStorage(userId);

        res.success = true;
        res.data = true;
      } else {
        res.success = false;
        res.errorMsg = walletRes.errorMsg;
      }
    } else {
      res.success = false;
      res.errorMsg = 'Usuário não encontrado';
    }

    return res;
  }

  Future<String> _encryptString(String input) async {
    final encrypted = base64Encode(utf8.encode(input));

    return encrypted;
  }

  Future<ResponseDto> loginByUid() async {
    ResponseDto res = ResponseDto();

    String? uid = await _getLastUserId();

    if (uid != null && uid.isNotEmpty) {
      User? user = await _userDao.loginByUid(uid);
      
      if (user != null && user.id.isNotEmpty) {
      _setUserIdToLocalStorage(uid);
      //TODO: Ver logica no waste
      // buscar carteiras
      currentUser = user;

      } else {
        _clearLocalStorage();
      }
    }

    res.success = true;
    res.data = true;

    return res;
  }

  Future<void> _setUserIdToLocalStorage(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setString('uid', uid);
  }

  Future<String?> _getLastUserId() async {
    String? uidStored;
    final prefs = await SharedPreferences.getInstance();
    uidStored = prefs.getString('uid');

    return uidStored;
  }

  Future<void> _clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

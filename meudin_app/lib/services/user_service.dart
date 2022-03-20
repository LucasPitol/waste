import 'package:meudin_app/models/dtos/new_user_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meudin_app/models/forms/new_user_form.dart';
import 'package:meudin_app/models/dtos/response_dto.dart';
import 'package:meudin_app/environment/environment.dart';
import 'package:meudin_app/models/forms/login_form.dart';
import 'package:meudin_app/models/dtos/member_dto.dart';
import 'package:meudin_app/models/wallet.dart';
import 'package:meudin_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'wallet_service.dart';

class UserService {
  static User? currentUser;
  String apiUrl = Environment.apiUrl;
  Map<String, String> headersRequest = Environment.headersRequest;

  late WalletService _walletService;

  UserService() {
    _walletService = WalletService();
  }

  static isAuthenticated() {
    return currentUser != null &&
        currentUser!.id != null &&
        currentUser!.id.isNotEmpty;
  }

  Future<ResponseDto> getMembersByMemberIds(List<String> memberIdList) async {
    Uri url = Uri.parse(this.apiUrl + 'getMembersByMemberIds');

    var responseData = await http.post(
      url,
      headers: headersRequest,
      body: jsonEncode(
        {
          'memberIdList': memberIdList,
        },
      ),
    );

    ResponseDto res = ResponseDto(responseData);

    List<MemberDto> memberDtoList = [];

    if (res.success) {
      memberDtoList = await _handleMemberDto(res.data);
    }

    res.data = memberDtoList;

    return res;
  }

  _handleMemberDto(List<dynamic> memberMapList) {
    List<MemberDto> memberDtoList = [];

    memberMapList.forEach((element) {
      var transactionDto = MemberDto.fromJson(element);

      memberDtoList.add(transactionDto);
    });

    return memberDtoList;
  }

  Future<ResponseDto> addMemberToWallet(
      String memberMail, String walletId) async {
    Uri url = Uri.parse(this.apiUrl + 'addMemberToWallet');

    var responseData = await http.post(
      url,
      headers: headersRequest,
      body: jsonEncode(
        {
          'memberMail': memberMail,
          'walletId': walletId,
        },
      ),
    );

    ResponseDto res = ResponseDto(responseData);

    return res;
  }

  Future<ResponseDto> updateUserWallets() async {
    Uri url = Uri.parse(this.apiUrl + 'getUserWallets');

    String uid = currentUser!.id;

    var responseData = await http.post(
      url,
      headers: headersRequest,
      body: jsonEncode(
        {
          'uid': uid,
        },
      ),
    );

    ResponseDto res = ResponseDto(responseData);

    if (res.success) {
      List<dynamic> walletListMap = res.data;

      List<Wallet> walletList = [];

      walletListMap.forEach((element) {
        Wallet wallet = _walletService.handleWallet(element);

        walletList.add(wallet);
      });

      currentUser!.walletList = walletList;
    }

    return res;
  }

  Future<ResponseDto> changePassword(String newPassword, String uid) async {
    Uri url = Uri.parse(this.apiUrl + 'changePassword');

    String passwordEncrypt = await _encryptString(newPassword);

    var responseData = await http.post(
      url,
      headers: headersRequest,
      body: jsonEncode(
        {
          'uid': uid,
          'password': passwordEncrypt,
        },
      ),
    );

    ResponseDto res = ResponseDto(responseData);

    return res;
  }

  Future<ResponseDto> logIn(LoginForm form) async {
    Uri url = Uri.parse(this.apiUrl + 'logIn');

    String userMail = form.userMail.text;
    String password = form.password.text;

    String passwordEncrypt = await _encryptString(password);

    var responseData = await http.post(
      url,
      headers: headersRequest,
      body: jsonEncode(
        {'email': userMail, 'password': passwordEncrypt},
      ),
    );

    ResponseDto res = ResponseDto(responseData);
    if (res.success) {
      User user = _handleUser(res.data);
      currentUser = user;

      await _setUserIdToLocalStorage(user.id);
    }

    return res;
  }

  User _handleUser(Map<String, dynamic> userMap) {
    User user = User();

    user.id = userMap['id'];
    user.displayName = userMap['displayName'];
    user.email = userMap['email'];

    user.creationDate = DateTime.parse(userMap['creationDate']);
    user.lastUpdate = userMap['lastUpdate'] != null
        ? DateTime.parse(userMap['lastUpdate'])
        : user.creationDate;
    user.currentWalletId = userMap['currentWalletId'];

    List<dynamic> walletListMap = userMap['walletList'];

    List<Wallet> walletList = [];

    walletListMap.forEach((element) {
      Wallet wallet = _walletService.handleWallet(element);

      walletList.add(wallet);
    });

    user.walletList = walletList;

    return user;
  }

  Future<ResponseDto> createNewUser(NewUserForm form) async {
    Uri url = Uri.parse(this.apiUrl + 'createNewUser');

    String name = form.name.text;
    String userMail = form.email.text;
    String password = form.password.text;

    String passwordEncrypt = await _encryptString(password);

    NewUserDto newUserDto = NewUserDto();

    newUserDto.name = name;
    newUserDto.email = userMail;
    newUserDto.password = passwordEncrypt;

    var jsonNewUserDto = newUserDto.toJson();

    var responseData = await http.post(
      url,
      headers: headersRequest,
      body: jsonEncode(
        {
          'newUserDto': jsonNewUserDto,
        },
      ),
    );

    ResponseDto res = ResponseDto(responseData);

    if (res.success) {
      User user = _handleUser(res.data);
      currentUser = user;

      await _setUserIdToLocalStorage(user.id);
    }

    return res;
  }

  Future<String> _encryptString(String input) async {
    final encrypted = base64Encode(utf8.encode(input));

    return encrypted;
  }

  Future<ResponseDto?> loginByUid() async {
    Uri url = Uri.parse(this.apiUrl + 'loginByUid');

    String? uid = await _getLastUserId();

    if (uid != null && uid.isNotEmpty) {
      var responseData = await http.post(
        url,
        headers: headersRequest,
        body: jsonEncode(
          {
            'uid': uid,
          },
        ),
      );

      ResponseDto res = ResponseDto(responseData);

      if (res.success) {
        User user = _handleUser(res.data);
        currentUser = user;
      }

      return res;
    } else {
      _clearLocalStorage();
      return null;
    }

  }

  int getNumberOfWalletsOwned() {
    var user = currentUser;
    List<Wallet> wallets = user!.walletList;

    int walletsOwned =
        wallets.where((element) => element.ownerId == user.id).length;

    return walletsOwned;
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

  Future<void> signOut() async {
    await _clearLocalStorage();
    currentUser = null;
  }
}

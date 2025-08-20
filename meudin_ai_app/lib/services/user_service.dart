import 'dart:convert';

import 'package:meudin_ai_app/services/local_storage_service.dart';
import 'package:meudin_ai_app/models/dtos/new_user_dto.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/environment/environment.dart';
import 'package:meudin_ai_app/models/wallet.dart';
import 'package:meudin_ai_app/models/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  static User? currentUser;
  String apiUrl = Environment.apiUrl;
  late LocalStorageService _localStorageService;

  UserService() {
    _localStorageService = LocalStorageService();
  }

  User? getCurrentUser() {
    return currentUser;
  }

  Future<ResponseDto> updateUserPassword({
    required String userMail,
    required String newPassword,
  }) async {
    Uri url = Uri.parse('${apiUrl}updatePassword');
    var token = currentUser?.token ?? '';
    var response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(
        {
          'userMail': userMail,
          'newPassword': newPassword,
        },
      ),
    );

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }

  Future<ResponseDto> validateVerificationCode({
    required String userMail,
    required String verificationCode,
  }) async {
    Uri url = Uri.parse('${apiUrl}validateVerificationCode');
    var token = currentUser?.token ?? '';

    var response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(
        {
          'userMail': userMail,
          'verificationCode': verificationCode,
        },
      ),
    );

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }

  Future<ResponseDto> sendVerificationCode({
    required String userMail,
    required String verificationType,
  }) async {
    Uri url = Uri.parse('${apiUrl}sendVerificationCode');
    var token = currentUser?.token ?? '';

    var response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "content-type": "application/json",
      },
      body: jsonEncode(
        {
          'userMail': userMail,
          'verificationType': verificationType,
        },
      ),
    );

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }

  Future<ResponseDto> signInByEmailAndPassword(
    String userMail,
    String password,
  ) async {
    Uri url = Uri.parse('${apiUrl}logIn');

    var response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
      },
      body: jsonEncode(
        {
          'email': userMail,
          'password': password,
        },
      ),
    );
    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    if (responseDto.success) {
      User user = _handleUser(responseDto.data);
      currentUser = user;
      await _localStorageService.storeUserData(user);
    }

    return responseDto;
  }

  Future<ResponseDto> createNewUser(NewUserDto newUserDto) async {
    Uri url = Uri.parse('${apiUrl}createNewUser');

    NewUserDto newUserDtoTemp = NewUserDto();
    newUserDtoTemp.email = newUserDto.email;
    newUserDtoTemp.name = newUserDto.name;
    newUserDtoTemp.password = newUserDto.password;

    var jsonNewUserDto = newUserDtoTemp.toJson();

    var response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
      },
      body: jsonEncode(
        {
          'newUserDto': jsonNewUserDto,
        },
      ),
    );

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }

  User _handleUser(Map<String, dynamic> userMap) {
    User user = User();

    user.id = userMap['id'];
    user.displayName = userMap['displayName'];
    user.email = userMap['email'];
    user.token = userMap['token'] ?? '';

    user.creationDate = DateTime.parse(userMap['creationDate']);
    user.lastUpdate = userMap['lastUpdate'] != null
        ? DateTime.parse(userMap['lastUpdate'])
        : user.creationDate;
    user.currentWalletId = userMap['currentWalletId'];

    List<dynamic> walletListMap = userMap['walletList'];

    List<Wallet> walletList = [];

    for (var element in walletListMap) {
      Wallet wallet = handleWallet(element);

      walletList.add(wallet);
    }

    user.walletList = walletList;

    return user;
  }

  Wallet handleWallet(Map<String, dynamic> walletMap) {
    Wallet wallet = Wallet();

    wallet.id = walletMap['id'];
    wallet.name = walletMap['name'];
    wallet.ownerId = walletMap['ownerId'];
    wallet.lastUpdate = DateTime.parse(walletMap['lastUpdate']);
    wallet.creationDate = DateTime.parse(walletMap['creationDate']);

    List<String> membersId = [];
    var membersIdMap = walletMap['membersIds'];
    for (var element in membersIdMap) {
      String id = element.toString();
      membersId.add(id);
    }

    wallet.membersIds = membersId;

    return wallet;
  }

  forceSignOut() {
    currentUser = null;
    _localStorageService.deleteUserData();
  }
}

import 'dart:convert';

import 'package:meudin_ai_app/services/local_storage_service.dart';
import 'package:meudin_ai_app/models/dtos/new_user_dto.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/environment/environment.dart';
import 'package:meudin_ai_app/services/wallet_service.dart';
import 'package:meudin_ai_app/models/wallet.dart';
import 'package:meudin_ai_app/models/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  static User? currentUser;
  String apiUrl = Environment.apiUrl;
  late LocalStorageService _localStorageService;
  late WalletService _walletService;

  UserService() {
    _localStorageService = LocalStorageService();
    _walletService = WalletService();
  }

  Future<ResponseDto> updateUserPassword({
    required String userMail,
    required String newPassword,
  }) async {
    Uri url = Uri.parse('${apiUrl}updatePassword');

    var response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
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

    var response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
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

    var response = await http.post(
      url,
      headers: {
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
    user.token = userMap['token'];

    user.creationDate = DateTime.parse(userMap['creationDate']);
    user.lastUpdate = userMap['lastUpdate'] != null
        ? DateTime.parse(userMap['lastUpdate'])
        : user.creationDate;
    user.currentWalletId = userMap['currentWalletId'];

    List<dynamic> walletListMap = userMap['walletList'];

    List<Wallet> walletList = [];

    for (var element in walletListMap) {
      Wallet wallet = _walletService.handleWallet(element);

      walletList.add(wallet);
    }

    user.walletList = walletList;

    return user;
  }

  static User? mockCurrentUser() {
    var wallet1 = Wallet();
    wallet1.membersIds = ['1'];
    wallet1.name = 'Wallet 1';
    wallet1.id = '1';
    wallet1.ownerId = '1';

    var wallet2 = Wallet();
    wallet2.membersIds = ['1', '2'];
    wallet2.name = 'Wallet 2';
    wallet2.id = '2';
    wallet2.ownerId = '2';

    var user = User();
    user.currentWalletId = wallet1.id;
    user.displayName = 'Severaldo Messi';
    user.email = 'mail@ll.com';
    user.walletList = [
      wallet1,
      wallet2,
    ];
    user.id = '1';

    currentUser = user;

    return currentUser;
  }

  updateUserWallets() {
    // request to get wallets
  }

  forceSignOut() {}
}

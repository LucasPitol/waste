import 'dart:convert';

import 'package:meudin_ai_app/services/local_storage_service.dart';
import 'package:meudin_ai_app/services/encryption_service.dart';
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
  late EncryptionService _encryptionService;
  late LocalStorageService _localStorageService;
  late WalletService _walletService;

  UserService() {
    _encryptionService = EncryptionService();
    _localStorageService = LocalStorageService();
    _walletService = WalletService();
  }

  Future<ResponseDto> createNewUser(NewUserDto newUserDto) async {
    Uri url = Uri.parse('${apiUrl}createNewUser');

    String passwordEncrypt =
        await _encryptionService.encryptString(newUserDto.password);

    newUserDto.password = passwordEncrypt;

    var jsonNewUserDto = newUserDto.toJson();

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

    if (responseDto.success) {
      User user = _handleUser(responseDto.data);
      // User user = User.fromJson(responseDto.data);
      currentUser = user;

      await _localStorageService.storeUserData(user);
    }

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

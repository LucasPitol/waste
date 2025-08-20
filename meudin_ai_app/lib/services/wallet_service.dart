import 'dart:convert';

import 'package:meudin_ai_app/environment/environment.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/models/wallet.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:meudin_ai_app/services/local_storage_service.dart';
import 'package:http/http.dart' as http;

class WalletService {
  String apiUrl = Environment.apiUrl;

  WalletService() {
    // Removed circular dependency
  }

  Future<ResponseDto> getUserWallets() async {
    final user = UserService.currentUser;
    final userId = user?.id;
    final authToken = user?.token;

    final url = Uri.parse('${apiUrl}getUserWallets');

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final body = jsonEncode({
      'uid': userId,
    });

    final response = await http.post(url, body: body, headers: headers);

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    if (responseDto.success) {
      var wallets = (responseDto.data as List)
          .map((walletMap) => handleWallet(walletMap))
          .toList();
      
      // Update the current user's wallet list
      if (UserService.currentUser != null) {
        UserService.currentUser!.walletList = wallets;
        
        // Optionally save the updated user to local storage
        final localStorageService = LocalStorageService();
        await localStorageService.storeUserData(UserService.currentUser!);
      }
    }

    return responseDto;
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

  updateUserWallets() {}
}

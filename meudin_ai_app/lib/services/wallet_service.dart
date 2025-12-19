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
    final authToken = user?.token;

    final url = Uri.parse('${apiUrl}wallet');

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final response = await http.get(url, headers: headers);

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    if (responseDto.success) {
      var wallets = (responseDto.data as List)
          .map((walletMap) => handleWallet(walletMap))
          .toList();
      
      // Update the current user's wallet list
      if (UserService.currentUser != null) {
        UserService.currentUser!.walletList = wallets;
        
        // Save the updated wallet list to secure storage
        final localStorageService = LocalStorageService();
        await localStorageService.updateWalletList(wallets);
      }
    }

    return responseDto;
  }

  Future<ResponseDto> createWallet(String walletName) async {
    final user = UserService.currentUser;
    final authToken = user?.token;

    final url = Uri.parse('${apiUrl}wallet');

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final body = jsonEncode({
      'walletName': walletName,
    });

    final response = await http.post(url, body: body, headers: headers);

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }

  Future<ResponseDto> addMemberToWallet(String walletId, String memberEmail) async {
    final user = UserService.currentUser;
    final authToken = user?.token;

    final url = Uri.parse('${apiUrl}wallet/add-member');

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final body = jsonEncode({
      'walletId': walletId,
      'memberEmail': memberEmail,
    });

    final response = await http.post(url, body: body, headers: headers);

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }

  Future<ResponseDto> removeMemberFromWallet(String walletId, String memberId) async {
    final user = UserService.currentUser;
    final authToken = user?.token;

    final url = Uri.parse('${apiUrl}wallet/remove-member');

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final body = jsonEncode({
      'walletId': walletId,
      'memberId': memberId,
    });

    final response = await http.post(url, body: body, headers: headers);

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }

  Future<ResponseDto> getWalletMembers(String walletId) async {
    final user = UserService.currentUser;
    final authToken = user?.token;

    final url = Uri.parse('${apiUrl}wallet/members?walletId=$walletId');

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final response = await http.get(url, headers: headers);

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }

  Wallet handleWallet(Map<String, dynamic> walletMap) {
    Wallet wallet = Wallet();

    wallet.id = walletMap['id'];
    wallet.name = walletMap['name'];
    wallet.ownerId = walletMap['ownerId'] ?? walletMap['owner_id'];
    
    // Handle dates with fallback
    if (walletMap['lastUpdate'] != null) {
      wallet.lastUpdate = DateTime.parse(walletMap['lastUpdate']);
    } else if (walletMap['updated_at'] != null) {
      wallet.lastUpdate = DateTime.parse(walletMap['updated_at']);
    } else {
      wallet.lastUpdate = DateTime.now();
    }
    
    if (walletMap['creationDate'] != null) {
      wallet.creationDate = DateTime.parse(walletMap['creationDate']);
    } else if (walletMap['created_at'] != null) {
      wallet.creationDate = DateTime.parse(walletMap['created_at']);
    } else {
      wallet.creationDate = DateTime.now();
    }

    List<String> membersId = [];
    var membersIdMap = walletMap['membersIds'];
    if (membersIdMap != null) {
      for (var element in membersIdMap) {
        String id = element.toString();
        membersId.add(id);
      }
    }

    wallet.membersIds = membersId;

    return wallet;
  }

  updateUserWallets() {}
}

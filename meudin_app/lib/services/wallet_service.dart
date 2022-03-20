import 'dart:convert';

import 'package:meudin_app/environment/environment.dart';
import 'package:meudin_app/models/dtos/response_dto.dart';
import 'package:meudin_app/models/wallet.dart';
import 'package:http/http.dart' as http;

class WalletService {
  String apiUrl = Environment.apiUrl;
  Map<String, String> headersRequest = Environment.headersRequest;

  Future<ResponseDto> getWalletsByUserId(String uid) async {
    Uri url = Uri.parse(this.apiUrl + 'getWalletsByUserId');

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

    return res;
  }

  Wallet handleWallet(Map<String, dynamic> walletMap) {
    Wallet wallet = Wallet();

    wallet.id = walletMap['id'];
    wallet.name = walletMap['name'];
    wallet.ownerId = walletMap['ownerId'];
    wallet.lastUpdate = DateTime.parse(walletMap['lastUpdate']);
    wallet.creationDate = DateTime.parse(walletMap['creationDate']);

    List<String> membersId = [];
    var membersIdMap = walletMap['membersId'];
    for (var element in membersIdMap) {
      String id = element.toString();
      membersId.add(id);
    }

    wallet.membersId = membersId;

    return wallet;
  }

  Future<ResponseDto> removeMember(String memberId, String walletId) async {
    Uri url = Uri.parse(this.apiUrl + 'removeMemberFromWallet');

    var responseData = await http.post(
      url,
      headers: headersRequest,
      body: jsonEncode(
        {
          'memberId': memberId,
          'walletId': walletId,
        },
      ),
    );

    ResponseDto res = ResponseDto(responseData);

    return res;
  }

  Future<ResponseDto> createNewWallet(String walletName, String userId) async {
    Uri url = Uri.parse(this.apiUrl + 'createNewWallet');

    var responseData = await http.post(
      url,
      headers: headersRequest,
      body: jsonEncode(
        {
          'walletName': walletName,
          'userId': userId,
        },
      ),
    );

    ResponseDto res = ResponseDto(responseData);

    return res;
  }
}

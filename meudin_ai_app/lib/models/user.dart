import 'package:meudin_ai_app/models/abstract_model.dart';

import 'wallet.dart';

class User extends AbstractModel {
  late String displayName;
  late String email;
  late String? token;

  late String currentWalletId;
  late List<Wallet> walletList;

  User() {
    walletList = [];
  }

  User.fromJson(Map<String, dynamic> json) {
    walletList = [];

    id = json['id'];
    displayName = json['displayName'];
    email = json['email'];
    currentWalletId = json['currentWalletId'];
    token = json['token'];
    creationDate = DateTime.parse(json['creationDate']);

    List<dynamic> walletListMap = json['walletList'];

    walletListMap.forEach((e) {
      final wallet = Wallet.fromJson(e);
      walletList.add(wallet);
    });
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'currentWalletId': currentWalletId,
        'token': token,
        'creationDate': creationDate.toIso8601String(),
      };
}

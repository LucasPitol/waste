import 'package:meudin_ai_app/models/wallet.dart';

class WalletService {

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
}
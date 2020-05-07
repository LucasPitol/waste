import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/wallet.dart';

import 'auth_service.dart';

class WalletService {
  final dbReference = Firestore.instance;

  bool isOwner(String walletId, String uid) {
    List<Wallet> wallets = getUserWallets();
    Wallet currentWallet = wallets.where((w) => w.id == walletId).first;
    return currentWallet.ownerId == uid;
  }

  List<Wallet> getUserWallets() {
    return AuthService.currentUser.walletList;
  }

  void switchWallet(String walletId) {
    AuthService.currentUser.currentWalletId = walletId;
  }

  String getCurrentWalletId() {
    return AuthService.currentUser.currentWalletId;
  }

  Future<List<Wallet>> getWalletsByUserId(String userId) async {
    List<Wallet> wallets = [];

    await dbReference
        .collection('wallets')
        .where('membersId', arrayContains: userId)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((doc) {
        String walletId = doc.documentID;
        var walletRef = doc.data;
        List<String> members = [];

        Timestamp creationDate = walletRef['creationDate'];
        DateTime creationDateFormated = creationDate.toDate();

        List<dynamic> membersDynamic = walletRef['membersId'];

        membersDynamic.forEach((item) {
          members.add(item);
        });

        Wallet wallet = Wallet(
          walletId,
          creationDateFormated,
          members,
          walletRef['name'],
          walletRef['ownerId'],
        );
        wallets.add(wallet);
      });
      return wallets.sort((a, b) => a.creationDate.compareTo(b.creationDate));
    }).catchError((onError) {
      print(onError);
      return wallets;
    });
    return wallets;
  }
}

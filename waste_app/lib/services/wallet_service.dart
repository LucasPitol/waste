import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/wallet.dart';

import 'auth_service.dart';

class WalletService {
  final dbReference = Firestore.instance;

  bool isOwner(String walletId, String uid) {
    List<Wallet> wallets = getUserWalletsLocal();
    Wallet currentWallet = wallets.where((w) => w.id == walletId).first;
    return currentWallet.ownerId == uid;
  }

  Wallet getWallet(String walletId) {
    List<Wallet> wallets = getUserWalletsLocal();
    return wallets.where((w) => w.id == walletId).first;
  }

  List<Wallet> getUserWalletsLocal() {
    return AuthService.currentUser.walletList;
  }

  void switchWallet(String walletId) {
    AuthService.currentUser.currentWalletId = walletId;
  }

  String getCurrentWalletId() {
    return AuthService.currentUser.currentWalletId;
  }

  Future<bool> createNewWallet(String walletName) async {
    bool success = false;

    String uid = AuthService.currentUser.uid;

    List<String> membersId = [uid];

    Timestamp creationDate = Timestamp.fromDate(DateTime.now());

    await dbReference.collection('wallets').add({
      'creationDate': creationDate,
      'membersId': membersId,
      'name': walletName,
      'ownerId': uid
    }).then((onValue) async {
      success = true;
      List<Wallet> wallets = await getWalletsByUserId(uid);

      updateUserWalletsLocal(wallets);

      return success;
    }).catchError((onError) {
      print(onError);
      return success;
    });

    return success;
  }

  Future<bool> deleteWallet(String walletId) async {
    bool success = false;

    await dbReference
        .collection('wallets')
        .document(walletId)
        .delete()
        .then((onValue) {
      AuthService.currentUser.walletList.remove((w) => w.id == walletId);
      AuthService.currentUser.currentWalletId =
          AuthService.currentUser.walletList[0].id;
      success = true;
      return success;
    }).catchError((onError) {
      print(onError);
      return success;
    });

    return success;
  }

  void updateUserWalletsLocal(List<Wallet> wallets) {
    AuthService.currentUser.walletList = wallets;
  }

  Future<bool> updateWallet(Wallet newWallet) async {
    bool success = false;

    String walletId = newWallet.id;

    Timestamp lastUpdate = Timestamp.fromDate(DateTime.now());

    await dbReference.collection('wallets').document(walletId).setData(
        {'name': newWallet.name, 'lastUpdate': lastUpdate},
        merge: true).then((onValue) {
      success = true;
      return success;
    }).catchError((onError) async {
      print(onError);

      List<Wallet> wallets = await getWalletsByUserId(newWallet.ownerId);

      updateUserWalletsLocal(wallets);

      return success;
    });
    return success;
  }

  Future<List<Wallet>> getWalletsByUserId(String userId) async {
    List<Wallet> wallets = [];

    await dbReference
        .collection('wallets')
        .where('membersId', arrayContains: userId)
        .getDocuments()
        .then((QuerySnapshot snapshot) async {
      var docs = snapshot.documents;

      if (docs.isEmpty) {
        var ok = await this.createNewWallet('Carteira Pessoal');

        await dbReference
            .collection('wallets')
            .where('membersId', arrayContains: userId)
            .getDocuments()
            .then((QuerySnapshot snapshot) async {
          docs = snapshot.documents;
        });
      }
      docs.forEach((doc) {
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

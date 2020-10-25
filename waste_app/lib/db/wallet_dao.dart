import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/smart_error.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/smart_error_service.dart';

class WalletDao {
  final dbReference = Firestore.instance;
  SmartErrorService smartErrorService = SmartErrorService();

  Future<bool> createNewWallet(
      String walletName, String uid, List<String> membersId) async {
    Timestamp creationDate = Timestamp.fromDate(DateTime.now());
    bool success = false;

    await dbReference.collection('wallets').add({
      'creationDate': creationDate,
      'membersId': membersId,
      'name': walletName,
      'ownerId': uid
    }).then((value) {
      success = true;
      return success;
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Create new wallet';
      errorDto.userId = uid;

      this.smartErrorService.saveError(errorDto);

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
        .then((onValue) async {
      success = true;
      return success;
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Delete wallet';
      errorDto.userId = AuthService.currentUser.uid;

      this.smartErrorService.saveError(errorDto);

      return success;
    });
    return success;
  }

  Future<Wallet> getWalletById(String walletId) async {
    Wallet wallet;

    await this
        .dbReference
        .collection('wallets')
        .document(walletId)
        .get()
        .then((value) {
      var objMap = value.data;
      List<String> members = [];

      var totalBalanceStr = objMap['totalBalance'];
      double totalBalance = totalBalanceStr != null
          ? double.parse(totalBalanceStr.toString())
          : 0.0;

      Timestamp creationDate = objMap['creationDate'];
      DateTime creationDateFormated = creationDate.toDate();

      List<dynamic> membersDynamic = objMap['membersId'];

      membersDynamic.forEach((item) {
        members.add(item);
      });

      wallet = Wallet(value.documentID, creationDateFormated, members,
          objMap['name'], objMap['ownerId'], totalBalance);

      return wallet;
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'get wallet ny id';
      errorDto.userId = AuthService.currentUser.uid;

      this.smartErrorService.saveError(errorDto);

      return wallet;
    });
    return wallet;
  }

  Future<bool> updateWallet(Wallet newWallet) async {
    bool success = false;

    String walletId = newWallet.id;

    Timestamp lastUpdate = Timestamp.fromDate(DateTime.now());

    await dbReference.collection('wallets').document(walletId).setData({
      'name': newWallet.name,
      'lastUpdate': lastUpdate,
      'totalBalance': newWallet.totalBalance,
      'membersId': newWallet.membersId
    }, merge: true).then((onValue) {
      success = true;
      return success;
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Update wallet';
      errorDto.userId = AuthService.currentUser.uid;

      this.smartErrorService.saveError(errorDto);

      return success;
    });

    return success;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/db/wallet_dao.dart';
import 'package:waste_app/models/dtos/member-dto.dart';
import 'package:waste_app/models/smart_error.dart';
import 'package:waste_app/models/wallet.dart';

import 'auth_service.dart';
import 'smart_error_service.dart';
import 'transactions_service.dart';

class WalletService {
  final dbReference = Firestore.instance;
  WalletDao dao = WalletDao();
  SmartErrorService smartErrorService = SmartErrorService();
  TransactionService transactionService = TransactionService();

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

  bool isWalletNameRepeated(String input) {
    List<Wallet> wallets = this.getUserWalletsLocal();

    Iterable<Wallet> containsList = wallets.where((w) => w.name == input);

    return containsList.isNotEmpty;
  }

  int getNumberOfWalletsOwned() {
    int walletsOwned = 0;
    var user = AuthService.currentUser;
    List<Wallet> wallets = user.walletList;

    wallets.forEach((element) {
      if (element.ownerId == user.uid) {
        walletsOwned++;
      }
    });
    return walletsOwned;
  }

  Future<bool> createNewWallet(String walletName) async {
    bool success = false;

    String uid = AuthService.currentUser.uid;

    List<String> membersId = [uid];

    success = await this.dao.createNewWallet(walletName, uid, membersId);

    List<Wallet> wallets = await getWalletsByUserId(uid);

    updateUserWalletsLocal(wallets);
    return success;
  }

  Future<bool> deleteWalletTransactions(String walletId) async {
    bool success =
        await this.transactionService.deleteTransactionsByWalletId(walletId);

    return success;
  }

  Future<bool> deleteWallet(String walletId, String userId) async {
    bool success = false;

    bool x = await this.deleteWalletTransactions(walletId);

    success = await this.dao.deleteWallet(walletId);

    if (success) {
      List<Wallet> wallets = await getWalletsByUserId(userId);

      updateUserWalletsLocal(wallets);

      AuthService.currentUser.currentWalletId =
          AuthService.currentUser.walletList[0].id;
    }
    return success;
  }

  void updateUserWalletsLocal(List<Wallet> wallets) {
    AuthService.currentUser.walletList = wallets;
  }

  Future<bool> updateWallet(Wallet newWallet) async {
    bool success = false;

    success = await this.dao.updateWallet(newWallet);

    if (!success) {
      List<Wallet> wallets = await getWalletsByUserId(newWallet.ownerId);

      updateUserWalletsLocal(wallets);
    }

    return success;
  }

  Future<List<MemberDto>> getMembersByWalletId(List<String> membersId) async {
    List<MemberDto> members = List<MemberDto>();

    String userId = AuthService.currentUser.uid;

    membersId.remove(userId);

    if (membersId.isNotEmpty) {
      await dbReference
          .collection('user')
          .where('uid', whereIn: membersId)
          .getDocuments()
          .then((QuerySnapshot snapshot) async {
        var docs = snapshot.documents;

        docs.forEach((item) {
          var obj = item.data;
          var uid = item.documentID;

          MemberDto member = MemberDto();
          member.email = obj['email'];
          member.id = uid;
          member.name = obj['displayName'];

          members.add(member);
        });
        return members;
      }).catchError((onError) {
        print(onError);

        SmartError errorDto = SmartError();
        errorDto.errorLog = onError.toString();
        errorDto.feature = 'Get wallet members';
        errorDto.userId = userId;

        this.smartErrorService.saveError(errorDto);

        return members;
      });
    }

    return members;
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

        var totalBalanceStr = walletRef['totalBalance'];

        double totalBalance = totalBalanceStr != null
            ? double.parse(totalBalanceStr.toString())
            : 0.0;

        Wallet wallet = Wallet(walletId, creationDateFormated, members,
            walletRef['name'], walletRef['ownerId'], totalBalance);
        wallets.add(wallet);
      });
      wallets.sort((a, b) => a.creationDate.compareTo(b.creationDate));
      this.updateUserWalletsLocal(wallets);
      return wallets;
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Get wallets by userId';
      errorDto.userId = userId;

      this.smartErrorService.saveError(errorDto);

      return wallets;
    });
    return wallets;
  }

  removeMember(String memberId, String walletId) async {
    Wallet wallet = await this.dao.getWalletById(walletId);

    List<String> walletMembers = wallet.membersId;

    walletMembers.remove(memberId);

    wallet.membersId = walletMembers;

    await this.dao.updateWallet(wallet);
  }

  addNewMember(String memberId, String walletId) async {
    Wallet wallet = await this.dao.getWalletById(walletId);

    List<String> walletMembers = wallet.membersId;

    walletMembers.add(memberId);

    wallet.membersId = walletMembers;

    await this.dao.updateWallet(wallet);
  }

  static incrementBallance(String walletId, double value) async {
    WalletDao walletDao = WalletDao();

    var wallet = await walletDao.getWalletById(walletId);

    double previousValue = wallet.totalBalance;

    double newBalance = previousValue + value;

    wallet.totalBalance = newBalance;

    var success = await walletDao.updateWallet(wallet);
  }

  static decrementBallance(String walletId, double value) async {
    WalletDao walletDao = WalletDao();

    var wallet = await walletDao.getWalletById(walletId);

    double previousValue = wallet.totalBalance;

    double newBalance = previousValue - value;

    wallet.totalBalance = newBalance;

    var success = await walletDao.updateWallet(wallet);
  }
}

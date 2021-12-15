import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meudin_app/models/smart_error.dart';
import 'package:meudin_app/models/wallet.dart';
import 'package:meudin_app/services/smart_error_service.dart';

class WalletDao {
  final dbReference = FirebaseFirestore.instance;
  final String _walletsCollectionName = 'wallets';

  late SmartErrorService _smartErrorService;

  WalletDao() {
    _smartErrorService = SmartErrorService();
  }

  // Future<String> updateMemberList(List<String> members, String walletId) async {
  //   var batch = dbReference.batch();

  //   var docRef = dbReference.collection(_walletsCollectionName).doc(walletId);

  //   DateTime lastUpdate = DateTime.now();

  //   batch.set(
  //     docRef,
  //     {
  //       'membersId': members,
  //       'lastUpdate': Timestamp.fromDate(lastUpdate),
  //     },
  //     SetOptions(merge: true),
  //   );

  //   await batch.commit();

  //   return '';
  // }

  // Future<List<Wallet>> getWalletsByUserId(String userId) async {
  //   List<Wallet> wallets = [];

  //   var snapShot = await dbReference
  //       .collection(_walletsCollectionName)
  //       .where('membersId', arrayContains: userId)
  //       .get();

  //   for (var item in snapShot.docs) {
  //     Wallet wallet = Wallet(item);

  //     wallets.add(wallet);
  //   }

  //   wallets.sort((a, b) => a.name.compareTo(b.name));
  //   // }).catchError((onError) {
  //   //   SmartError errorDto = SmartError();
  //   //   errorDto.errorData = onError;
  //   //   errorDto.errorLog = onError.toString();
  //   //   errorDto.feature = 'Get wallets by user id';
  //   //   errorDto.userId = userId;
  //   //   errorDto.userMail = '';

  //   //   _smartErrorService.saveError(errorDto);
  //   // });

  //   return wallets;
  // }

  // Future<String> createNewWallet(String walletName, String ownerId) async {
  //   Timestamp creationDate = Timestamp.fromDate(DateTime.now());

  //   var batch = dbReference.batch();

  //   var docRef = dbReference.collection(_walletsCollectionName).doc();

  //   String id = docRef.id;

  //   List<String> membersId = [ownerId];

  //   batch.set(docRef, {
  //     'id': id,
  //     'name': walletName,
  //     'ownerId': ownerId,
  //     'membersId': membersId,
  //     'creationDate': creationDate,
  //   });

  //   await batch.commit().then((value) {
  //     return id;
  //   }).catchError((onError) {
  //     SmartError errorDto = SmartError();
  //     errorDto.errorData = onError;
  //     errorDto.errorLog = onError.toString();
  //     errorDto.feature = 'Create new wallet';
  //     errorDto.userId = id;
  //     errorDto.userMail = '';

  //     _smartErrorService.saveError(errorDto);
  //     return '';
  //   });

  //   return id;
  // }
}

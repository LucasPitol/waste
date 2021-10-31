import 'package:cloud_firestore/cloud_firestore.dart';

import 'abstract_model.dart';
import 'wallet.dart';

class User extends AbstractModel {
  late String name;
  late String email;

  late String currentWalletId;
  late List<Wallet> walletList;

  User(DocumentSnapshot doc) {
    Map<String, dynamic> objMapp = doc.data() as Map<String, dynamic>;

    Timestamp creationDateTimestamp = objMapp['creationDate'];

    id = doc.id;
    name = objMapp['displayName'];
    email = objMapp['email'];
    creationDate = creationDateTimestamp.toDate();

    walletList = <Wallet>[];
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import 'abstract_model.dart';

class TransactionModel extends AbstractModel {
  late double amount;
  late String? categoryId;
  late String reason;
  late DateTime transactionDate;
  late String type;
  late String userId;
  late String walletId;

  TransactionModel(DocumentSnapshot doc) {
    Map<String, dynamic> objMapp = doc.data() as Map<String, dynamic>;

    Timestamp creationDateTimestamp = objMapp['creationDate'];
    Timestamp transactionDateTimestamp = objMapp['transactionDate'];

    id = doc.id;
    amount = double.parse(objMapp['amount'].toString());

    categoryId = objMapp['categoryId'];
    reason = objMapp['reason'];
    type = objMapp['type'];
    userId = objMapp['userId'];
    walletId = objMapp['walletId'];
    transactionDate = transactionDateTimestamp.toDate();
    creationDate = creationDateTimestamp.toDate();
  }
}

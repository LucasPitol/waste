import 'package:cloud_firestore/cloud_firestore.dart';

class Spend {
  DateTime creationDate;
  String categoryId;
  String reason;
  DateTime spendDate;
  String userId;
  String walletId;
  double waste;

  Spend(DocumentSnapshot doc) {
    var objMapp = doc.data;

    Timestamp spendDateTimestamp = objMapp['spendDate'];
    Timestamp creationDateTimestamp = objMapp['creationDate'];

    this.creationDate = creationDateTimestamp.toDate();
    this.reason = objMapp['reason'];
    this.spendDate = spendDateTimestamp.toDate();
    this.userId = objMapp['userId'];
    this.walletId = objMapp['walletId'];
    this.categoryId = objMapp['categoryId'];

    this.waste = double.parse(objMapp['waste'].toString());
  }
}
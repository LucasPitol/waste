import 'package:cloud_firestore/cloud_firestore.dart';

class Spend {
  DateTime creationDate;
  String reason;
  DateTime spendDate;
  String userId;
  String walletId;
  double waste;

  Spend(DocumentSnapshot doc) {
    var objMapp = doc.data;

    this.creationDate = objMapp['creationDate'];
    this.reason = objMapp['reason'];
    this.spendDate = objMapp['spendDate'];
    this.userId = objMapp['userId'];
    this.walletId = objMapp['walletId'];
    this.waste = objMapp['waste'];
  }
}
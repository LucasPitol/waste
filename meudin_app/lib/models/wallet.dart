import 'package:cloud_firestore/cloud_firestore.dart';

import 'abstract_model.dart';

class Wallet extends AbstractModel {
  late List<String> membersId;
  late String name;
  late String ownerId;

  Wallet() {
    membersId = [];
  }

  // Wallet(DocumentSnapshot doc) {
  //   Map<String, dynamic> objMapp = doc.data() as Map<String, dynamic>;

  //   Timestamp creationDateTimestamp = objMapp['creationDate'];

  //   List<dynamic> membersIdDynamic = objMapp['membersId'];

  //   membersId = [];
  //   for (var element in membersIdDynamic) {
  //     String id = element.toString();
  //     membersId.add(id);
  //   }

  //   id = doc.id;
  //   name = objMapp['name'];
  //   ownerId = objMapp['ownerId'];
  //   creationDate = creationDateTimestamp.toDate();
  // }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import 'abstract_model.dart';

class SpendingCategory extends AbstractModel {
  late String name;
  late String value;

  SpendingCategory(DocumentSnapshot doc) {
    Map<String, dynamic> objMapp = doc.data() as Map<String, dynamic>;

    Timestamp? creationDateTimestamp = objMapp['creationDate'];

    id = doc.id;
    name = objMapp['displayNamePt'];
    value = objMapp['value'];
    creationDate = creationDateTimestamp != null
        ? creationDateTimestamp.toDate()
        : DateTime(1900, 01, 01);
  }
}

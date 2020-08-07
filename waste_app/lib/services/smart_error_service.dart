import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/smart_error.dart';

class SmartErrorService {

  final dbReference = Firestore.instance;

  Future<void> saveError(SmartError errorDto) async {

    Timestamp creationDate = Timestamp.fromDate(DateTime.now());

    await dbReference.collection('errors').add({
      'creationDate': creationDate,
      'errorLog': errorDto.errorLog,
      'feature': errorDto.feature,
      'userId': errorDto.userId
    }).catchError((onError) {
      print(onError);
    });
  }
}
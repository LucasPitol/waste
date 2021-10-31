import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meudin_app/models/smart_error.dart';

class SmartErrorService {
  final dbReference = FirebaseFirestore.instance;

  Future<void> saveError(SmartError errorDto) async {

    Timestamp creationDate = Timestamp.fromDate(DateTime.now());

    await dbReference.collection('errors').add({
      'creationDate': creationDate,
      'errorData': errorDto.errorData,
      'errorLog': errorDto.errorLog,
      'userMail': errorDto.userId,
      'feature': errorDto.feature,
      'userId': errorDto.userMail,
    }).catchError((onError) {
      print(onError);
    });
  }
}
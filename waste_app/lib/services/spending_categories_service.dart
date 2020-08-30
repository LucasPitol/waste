import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/smart_error.dart';

import 'auth_service.dart';
import 'smart_error_service.dart';

class SpendingCategoriesService {
  final dbReference = Firestore.instance;
  SmartErrorService smartErrorService = SmartErrorService();

  void incrementSpendsWithThisCategory(String categoryId) {
    DocumentReference docRef =
        this.dbReference.collection('spendingCategories').document(categoryId);

    docRef.get().then((value) {
      var category = value.data;

      int previousSpendsCount = category['spendsWithThisCategoryCount'];

      if (previousSpendsCount == null) {
        previousSpendsCount = 0;
      }

      int newSpendCount = (previousSpendsCount + 1);

      docRef.setData({
        'spendsWithThisCategoryCount': newSpendCount,
      }, merge: true).catchError((onError) {
        print(onError);
        SmartError errorDto = SmartError();
        errorDto.errorLog = onError.toString();
        errorDto.feature = 'Waste (update spendingCategories)';
        errorDto.userId = AuthService.currentUser.uid;

        this.smartErrorService.saveError(errorDto);
      });
    });
  }
}

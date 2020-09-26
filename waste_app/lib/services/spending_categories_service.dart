import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/smart_error.dart';
import 'package:waste_app/models/spending_category.dart';
import 'package:waste_app/utils/constants.dart';

import 'auth_service.dart';
import 'smart_error_service.dart';

class SpendingCategoriesService {
  final dbReference = Firestore.instance;
  SmartErrorService smartErrorService = SmartErrorService();

  Future<List<SpendingCategory>> getSpendingCategories() async {
    bool isPtLanguage =
        AuthService.currentUser.language == Constants.languages[0];

    List<SpendingCategory> categories = List<SpendingCategory>();

    await this
        .dbReference
        .collection('spendingCategories')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((item) {
        String categoryId = item.documentID;

        var obj = item.data;

        String ptName = obj['displayNamePt'];
        String enName = obj['displayNameEn'];
        String value = obj['value'];

        SpendingCategory category =
            SpendingCategory(categoryId, ptName, enName, value);
        categories.add(category);
      });
      return isPtLanguage
          ? (categories
              .sort((a, b) => a.displayNamePt.compareTo(b.displayNamePt)))
          : (categories
              .sort((a, b) => a.displayNameEn.compareTo(b.displayNameEn)));
    }).catchError((onError) {
      print(onError);

      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'Get list categories';
      errorDto.userId = AuthService.currentUser.uid;

      this.smartErrorService.saveError(errorDto);
      return categories;
    });
    return categories;
  }

  void decrementSpendsWithThisCategory(String categoryId) {
    DocumentReference docRef =
        this.dbReference.collection('spendingCategories').document(categoryId);

    docRef.get().then((value) {
      var category = value.data;

      int previousSpendsCount = category['spendsWithThisCategoryCount'];

      if (previousSpendsCount != null && previousSpendsCount > 0) {
        int newSpendCount = (previousSpendsCount - 1);

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
      }
    });
  }

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

  Future<List<SpendingCategory>> getCategoriesById(
      List<String> categoryIdItems) async {
    bool isPtLanguage =
        AuthService.currentUser.language == Constants.languages[0];
    List<SpendingCategory> categories = List<SpendingCategory>();

    await this
        .dbReference
        .collection('spendingCategories')
        .where('categoryId', whereIn: categoryIdItems)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((element) {
        String categoryId = element.documentID;
        var obj = element.data;

        SpendingCategory category = SpendingCategory(categoryId,
            obj['displayNamePt'], obj['displayNameEn'], obj['value']);

        categories.add(category);
      });
      return isPtLanguage
          ? (categories
              .sort((a, b) => a.displayNamePt.compareTo(b.displayNamePt)))
          : (categories
              .sort((a, b) => a.displayNameEn.compareTo(b.displayNameEn)));
    }).catchError((onError) {
      print(onError);
      SmartError errorDto = SmartError();
      errorDto.errorLog = onError.toString();
      errorDto.feature = 'get spendingCategories by ids';
      errorDto.userId = AuthService.currentUser.uid;

      this.smartErrorService.saveError(errorDto);

      return categories;
    });
    return categories;
  }
}

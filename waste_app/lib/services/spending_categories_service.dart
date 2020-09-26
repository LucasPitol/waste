import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/db/spending_category_dao.dart';
import 'package:waste_app/models/smart_error.dart';
import 'package:waste_app/models/spending_category.dart';
import 'package:waste_app/utils/constants.dart';

import 'auth_service.dart';
import 'smart_error_service.dart';

class SpendingCategoriesService {
  final dbReference = Firestore.instance;
  SpendingCategoryDao dao = SpendingCategoryDao();
  SmartErrorService smartErrorService = SmartErrorService();

  Future<List<SpendingCategory>> getSpendingCategories() async {
    bool isPtLanguage =
        AuthService.currentUser.language == Constants.languages[0];

    List<SpendingCategory> categories = await this.dao.getSpendingCategories();

    if (isPtLanguage) {
      categories.sort((a, b) => a.displayNamePt.compareTo(b.displayNamePt));
    } else {
      categories.sort((a, b) => a.displayNameEn.compareTo(b.displayNameEn));
    }

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
    List<SpendingCategory> categories =
        await this.dao.getCategoriesById(categoryIdItems);

    if (isPtLanguage) {
      categories.sort((a, b) => a.displayNamePt.compareTo(b.displayNamePt));
    } else {
      categories.sort((a, b) => a.displayNameEn.compareTo(b.displayNameEn));
    }

    return categories;
  }
}

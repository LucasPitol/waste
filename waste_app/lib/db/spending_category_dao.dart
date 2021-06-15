import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/smart_error.dart';
import 'package:waste_app/models/spending_category.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/smart_error_service.dart';

class SpendingCategoryDao {
  final dbReference = FirebaseFirestore.instance;
  SmartErrorService smartErrorService = SmartErrorService();

  Future<List<SpendingCategory>> getSpendingCategories() async {
    List<SpendingCategory> categories = [];

    await this
        .dbReference
        .collection('spendingCategories')
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((item) {
        String categoryId = item.id;

        Map<String, dynamic> obj = item.data();

        String ptName = obj['displayNamePt'];
        String enName = obj['displayNameEn'];
        String value = obj['value'];

        SpendingCategory category =
            SpendingCategory(categoryId, ptName, enName, value);
        categories.add(category);
      });
      return categories;
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

  Future<List<SpendingCategory>> getCategoriesById(
      List<String> categoryIdItems) async {
    List<SpendingCategory> categories = [];

    await this
        .dbReference
        .collection('spendingCategories')
        .where('categoryId', whereIn: categoryIdItems)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((element) {
        String categoryId = element.id;
        Map<String, dynamic> obj = element.data();

        SpendingCategory category = SpendingCategory(categoryId,
            obj['displayNamePt'], obj['displayNameEn'], obj['value']);

        categories.add(category);
      });
      return categories;
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

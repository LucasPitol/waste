import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meudin_app/models/spending_category.dart';
import 'package:meudin_app/services/smart_error_service.dart';

class SpendingCategoryDao {
  final dbReference = FirebaseFirestore.instance;
  final String _spendingCategoryCollectionName = 'spendingCategories';

  late SmartErrorService _smartErrorService;

  SpendingCategoryDao() {
    _smartErrorService = SmartErrorService();
  }

  Future<List<SpendingCategory>> getSpendingCategories() async {
    List<SpendingCategory> spendingCategories = <SpendingCategory>[];

    var snapShot =
        await dbReference.collection(_spendingCategoryCollectionName).get();

    for (var item in snapShot.docs) {
      SpendingCategory pendingCategory = SpendingCategory(item);

      spendingCategories.add(pendingCategory);
    }

    return spendingCategories;
  }
}

import 'package:waste_app/models/dtos/graph_category_dto.dart';
import 'package:waste_app/models/dtos/profile_dto.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/db/transactions_dao.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/utils/constants.dart';
import 'spending_categories_service.dart';
import 'smart_error_service.dart';

class SpendsService {
  TransactionsDao transactionsDao = TransactionsDao();
  SmartErrorService smartErrorService = SmartErrorService();
  SpendingCategoriesService spendingCategoriesService =
      SpendingCategoriesService();

  

  Future<ProfileDto> getProfileData(
      DateTime startDate, DateTime endDate) async {
    var profileData = ProfileDto();
    Map<String, double> spendsByCategoryMapLocal = new Map<String, double>();
    var graphItemList = List<GraphCategoryDto>();
    double totalWaste = 0.0;

    if (startDate == null) {
      DateTime today = DateTime.now();

      startDate = DateTime(today.year, 1, 1);

      endDate = today;
    }
    Timestamp startDateTimestamp = Timestamp.fromDate(startDate);

    Timestamp endDateTimestamp = Timestamp.fromDate(endDate);

    UserDto user = AuthService.currentUser;
    bool isPt = user.language == Constants.languages[0];
    String walletId = user.currentWalletId;

    var categories =
        await this.spendingCategoriesService.getSpendingCategories();

    var spends = await this.transactionsDao.getSpendsByDateInterval(
        walletId, startDateTimestamp, endDateTimestamp);

    spends.forEach((spend) {
      double waste = spend.waste;
      totalWaste = totalWaste + waste;

      var wasteCategoryId = spend.categoryId;

      if (wasteCategoryId != null) {
        var category =
            categories.where((element) => element.id == wasteCategoryId).first;

        String key = isPt ? category.displayNamePt : category.displayNameEn;

        var graphItem = GraphCategoryDto();

        if (spendsByCategoryMapLocal.containsKey(key)) {
          double wasteByCategory = spendsByCategoryMapLocal[key];

          wasteByCategory = wasteByCategory + waste;

          spendsByCategoryMapLocal.remove(key);

          spendsByCategoryMapLocal.putIfAbsent(key, () => wasteByCategory);
        } else {
          spendsByCategoryMapLocal.putIfAbsent(key, () => waste);
        }
      }
    });

    profileData.totalWaste = totalWaste;

    var sortedKeys = spendsByCategoryMapLocal.keys.toList(growable: false)
      ..sort((k1, k2) =>
          spendsByCategoryMapLocal[k2].compareTo(spendsByCategoryMapLocal[k1]));
    var sortedMap = Map<String, double>.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => spendsByCategoryMapLocal[k]);

    double totalOthers = 0.0;

    for (int i = 0; i < sortedKeys.length; i++) {
      if (i >= 3) {
        totalOthers = totalOthers + (sortedMap[sortedKeys[i]]);

        sortedMap.remove(sortedKeys[i]);

        if (i == (sortedKeys.length - 1)) {
          String key = isPt ? 'Demais' : 'The others';
          sortedMap.putIfAbsent(key, () => totalOthers);
        }
      }
    }

    profileData.spendsByCategoryMap = sortedMap;
    return profileData;
  }
  
}

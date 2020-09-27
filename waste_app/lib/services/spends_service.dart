import 'package:waste_app/models/forms/edit_waste_form.dart';
import 'package:waste_app/models/dtos/graph_category_dto.dart';
import 'package:waste_app/models/dtos/spend_by_month_dto.dart';
import 'package:waste_app/models/forms/new_waste_form.dart';
import 'package:waste_app/models/dtos/spend_item_dto.dart';
import 'package:waste_app/models/dtos/profile_dto.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/db/spends_dao.dart';
import 'spending_categories_service.dart';
import 'smart_error_service.dart';

class SpendsService {
  SpendsDao dao = SpendsDao();
  SmartErrorService smartErrorService = SmartErrorService();
  SpendingCategoriesService spendingCategoriesService =
      SpendingCategoriesService();

  Future<bool> waste(NewWasteForm form) async {
    bool success = false;

    String categoryId = form.categoryId;

    success = await this.dao.saveNewWaste(form);

    this.spendingCategoriesService.incrementSpendsWithThisCategory(categoryId);

    return success;
  }

  Future<bool> updateWaste(
      EditWasteForm form, String previousCategoryId) async {
    bool success = false;

    success = await this.dao.updateWaste(form);

    String categoryId = form.categoryId;

    if (categoryId != previousCategoryId) {
      this
          .spendingCategoriesService
          .decrementSpendsWithThisCategory(previousCategoryId);
      this
          .spendingCategoriesService
          .incrementSpendsWithThisCategory(categoryId);
    }

    return success;
  }

  Future<bool> deleteWastesByWalletId(String walletId) async {
    return await this.dao.deleteWastesByWalletId(walletId);
  }

  Future<bool> deleteWaste(String spendId, String spendCategoryId) async {
    bool success = false;

    success = await this.dao.deleteWaste(spendId);

    this
        .spendingCategoriesService
        .decrementSpendsWithThisCategory(spendCategoryId);

    return success;
  }

  Future<List<SpendByMonthDto>> getSpendsByMonthDtoList() async {
    List<SpendByMonthDto> spendsByMonthDtoList = [];

    String walletId = AuthService.currentUser.currentWalletId;

    var spends = await this.dao.getSpendsByWalletId(walletId);

    spends.forEach((spend) {
      DateTime spendDateComplete = spend.spendDate;
      DateTime spendYearAndMonth =
          DateTime(spendDateComplete.year, spendDateComplete.month);

      var spendItem =
          spendsByMonthDtoList.where((i) => i.date == spendYearAndMonth);
      double waste = spend.waste;

      if (spendItem.isEmpty) {
        SpendByMonthDto newDto = SpendByMonthDto(spendYearAndMonth, waste);
        spendsByMonthDtoList.add(newDto);
      } else {
        int index =
            spendsByMonthDtoList.indexWhere((i) => i.date == spendYearAndMonth);
        SpendByMonthDto oldDto = spendsByMonthDtoList.elementAt(index);
        double oldWaste = oldDto.spent;
        double newWaste = oldWaste + waste;
        SpendByMonthDto newDto = SpendByMonthDto(spendYearAndMonth, newWaste);
        spendsByMonthDtoList[index] = newDto;
      }
    });
    spendsByMonthDtoList.sort((a, b) => b.date.compareTo(a.date));
    return spendsByMonthDtoList;
  }

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

    var spends = await this.dao.getSpendsByDateInterval(
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

  Future<List<SpendItem>> getSpendsByMonthFiltered(
      DateTime completeDate, String categoryId) async {
    List<SpendItem> spendsList = List<SpendItem>();

    DateTime fistDayOfCurrentMonth =
        DateTime(completeDate.year, completeDate.month, 1);

    Timestamp fistDayOfCurrentMonthTimestamp =
        Timestamp.fromDate(fistDayOfCurrentMonth);

    DateTime firstDayOfNextMonth =
        DateTime(completeDate.year, completeDate.month + 1, 1, 23, 59, 59);

    DateTime lastDayOfCurrentMonth =
        firstDayOfNextMonth.add(Duration(days: -1));

    Timestamp lastDayOfCurrentMonthTimestamp =
        Timestamp.fromDate(lastDayOfCurrentMonth);

    UserDto user = AuthService.currentUser;
    String walletId = user.currentWalletId;

    var spends = await this.dao.getSpendsByDAteIntervalAndCategoryId(
        walletId,
        fistDayOfCurrentMonthTimestamp,
        lastDayOfCurrentMonthTimestamp,
        categoryId);

    spends.forEach((item) {
      String spendId = item.spendId;

      DateTime spendDate = item.spendDate;
      double waste = item.waste;

      var spend = SpendItem(item.userId, item.reason, spendDate, waste, spendId,
          item.walletId, item.categoryId);

      spendsList.add(spend);
    });
    spendsList.sort((a, b) => b.spendDate.compareTo(a.spendDate));

    return spendsList;
  }

  Future<List<SpendItem>> getSpendsByMonth(DateTime completeDate) async {
    List<SpendItem> spendsList = List<SpendItem>();

    DateTime fistDayOfCurrentMonth =
        DateTime(completeDate.year, completeDate.month, 1);

    Timestamp startDate = Timestamp.fromDate(fistDayOfCurrentMonth);

    DateTime firstDayOfNextMonth =
        DateTime(completeDate.year, completeDate.month + 1, 1, 23, 59, 59);

    DateTime lastDayOfCurrentMonth =
        firstDayOfNextMonth.add(Duration(days: -1));

    Timestamp endDate = Timestamp.fromDate(lastDayOfCurrentMonth);

    UserDto user = AuthService.currentUser;
    String walletId = user.currentWalletId;

    var spends =
        await this.dao.getSpendsByDateInterval(walletId, startDate, endDate);

    spends.forEach((item) {
      String spendId = item.spendId;

      DateTime spendDate = item.spendDate;
      double waste = item.waste;

      var spend = SpendItem(item.userId, item.reason, spendDate, waste, spendId,
          item.walletId, item.categoryId);

      spendsList.add(spend);
    });
    spendsList.sort((a, b) => b.spendDate.compareTo(a.spendDate));

    return spendsList;
  }
}

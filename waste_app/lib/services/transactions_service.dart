import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:waste_app/db/transactions_dao.dart';
import 'package:waste_app/models/dtos/graph_category_dto.dart';
import 'package:waste_app/models/dtos/overview_page_dto.dart';
import 'package:waste_app/models/dtos/profits_block_dto.dart';
import 'package:waste_app/models/dtos/spend_by_month_dto.dart';
import 'package:waste_app/models/dtos/spend_item_dto.dart';
import 'package:waste_app/models/dtos/transaction_block_dto.dart';
import 'package:waste_app/models/dtos/transaction_dto.dart';
import 'package:waste_app/models/forms/edit_waste_form.dart';
import 'package:waste_app/models/forms/new_revenue_form.dart';
import 'package:waste_app/models/forms/new_waste_form.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/services/smart_error_service.dart';
import 'package:waste_app/utils/constants.dart';

import 'auth_service.dart';
import 'spending_categories_service.dart';
import 'wallet_service.dart';

class TransactionService {
  final dbReference = Firestore.instance;
  TransactionsDao transactionsDao = TransactionsDao();
  SmartErrorService smartErrorService = SmartErrorService();
  SpendingCategoriesService spendingCategoriesService =
      SpendingCategoriesService();

  Future<bool> waste(NewWasteForm form) async {
    bool success = false;

    String categoryId = form.categoryId;

    success = await this.transactionsDao.saveNewWaste(form);

    this.spendingCategoriesService.incrementSpendsWithThisCategory(categoryId);

    return success;
  }

  Future<bool> updateWaste(
      EditWasteForm form, EditWasteForm previousForm) async {
    bool success = false;

    success = await this.transactionsDao.updateWaste(form);

    String walletId = form.walletId;

    String categoryId = form.categoryId;
    String previousCategoryId = previousForm.categoryId;

    if (categoryId != previousCategoryId) {
      this
          .spendingCategoriesService
          .decrementSpendsWithThisCategory(previousCategoryId);
      this
          .spendingCategoriesService
          .incrementSpendsWithThisCategory(categoryId);
    }

    String wasteString = form.waste.text.replaceAll(',', '');
    double waste = double.parse(wasteString);

    if (waste > 0) {
      waste = waste * (-1);
    }

    String previousWasteString = previousForm.waste.text.replaceAll(',', '');
    double previousWaste = double.parse(previousWasteString);

    if (previousWaste > 0) {
      previousWaste = previousWaste * (-1);
    }

    if (waste != previousWaste) {
      await WalletService.decrementBallance(walletId, previousWaste);
      await WalletService.incrementBallance(walletId, waste);
    }

    return success;
  }

  Future<bool> deleteWaste(String transactionId, String spendCategoryId,
      String walletId, double spent) async {
    bool success = false;

    success =
        await this.transactionsDao.deleteWaste(transactionId, walletId, spent);

    this
        .spendingCategoriesService
        .decrementSpendsWithThisCategory(spendCategoryId);

    return success;
  }

  Future<bool> deleteTransactionsByWalletId(String walletId) async {
    return await this.transactionsDao.deleteTransactionsByWalletId(walletId);
  }

  Future<List<SpendByMonthDto>> getSpendsByMonthDtoList() async {
    List<SpendByMonthDto> spendsByMonthDtoList = [];

    String walletId = AuthService.currentUser.currentWalletId;

    DateTime today = DateTime.now();

    int sixMonthsInDays = Constants.sixMonthsInDays;

    DateTime startDateRaw = today.subtract(Duration(days: sixMonthsInDays));
    DateTime startDate = DateTime(startDateRaw.year, startDateRaw.month, 1);

    Timestamp startDateTimestamp = Timestamp.fromDate(startDate);

    var spends = await this
        .transactionsDao
        .getSpendsByWalletId(walletId, startDateTimestamp);

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

  Future<OverviewPageDto> getOverviewPageData(
      DateTime startDate, DateTime endDate) async {
    OverviewPageDto pageDto = OverviewPageDto();
    Map<String, double> spendsByCategoryMapLocal = Map<String, double>();

    UserDto user = AuthService.currentUser;
    String walletId = user.currentWalletId;
    bool isPt = user.language == Constants.languages[0];

    Timestamp startDateTimestamp = Timestamp.fromDate(startDate);
    Timestamp endDateTimestamp = Timestamp.fromDate(endDate);

    var transactions = await this.transactionsDao.getTransactionsByDateInterval(
        walletId, startDateTimestamp, endDateTimestamp);

    var categories =
        await this.spendingCategoriesService.getSpendingCategories();

    double income = 0;
    double spends = 0;
    double balance = 0;

    transactions.forEach((element) {
      double amount = element.amount;

      if (amount >= 0) {
        income = income + amount;
      } else {
        spends = spends + amount;

        var wasteCategoryId = element.categoryId;

        if (wasteCategoryId != null) {
          var category = categories
              .where((element) => element.id == wasteCategoryId)
              .first;

          String key = isPt ? category.displayNamePt : category.displayNameEn;

          if (spendsByCategoryMapLocal.containsKey(key)) {
            double wasteByCategory = spendsByCategoryMapLocal[key];

            wasteByCategory = wasteByCategory + amount;

            spendsByCategoryMapLocal.remove(key);

            spendsByCategoryMapLocal.putIfAbsent(key, () => wasteByCategory);
          } else {
            spendsByCategoryMapLocal.putIfAbsent(key, () => amount);
          }
        }
      }
    });

    var sortedKeys = spendsByCategoryMapLocal.keys.toList(growable: false)
      ..sort((k1, k2) =>
          spendsByCategoryMapLocal[k1].compareTo(spendsByCategoryMapLocal[k2]));
    var sortedMap = Map<String, double>.fromIterable(sortedKeys,
        key: (k) => k, value: (k) => spendsByCategoryMapLocal[k]);

    double totalOthers = 0.0;

    for (int i = 0; i < sortedKeys.length; i++) {
      if (i >= 3) {
        totalOthers = totalOthers + (sortedMap[sortedKeys[i]]);

        sortedMap.remove(sortedKeys[i]);

        if (i == (sortedKeys.length - 1)) {
          String key = isPt ? 'Demais' : 'Others';
          sortedMap.putIfAbsent(key, () => totalOthers);
        }
      }
    }

    balance = income + spends;

    pageDto.income = income;
    pageDto.spends = spends;
    pageDto.balance = balance;
    pageDto.spendsByCategoryMap = sortedMap;

    return pageDto;
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

    var spends = await this
        .transactionsDao
        .getSpendsByDateInterval(walletId, startDate, endDate);

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

  Future<TransactionBlockDto> getTransactionsByWalletId(String walletId) async {
    return await this.transactionsDao.getTransactionsByWalletId(walletId);
  }

  Future<List<TransactionDto>> getLast2Transactions(String walletId) async {
    return await this.transactionsDao.getLast2Transactions(walletId);
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

    var spends = await this
        .transactionsDao
        .getSpendsByDateIntervalAndCategoryId(
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

  Future<List<ProfitsBlockDto>> getProfitsByMonth() async {
    List<ProfitsBlockDto> profitsBlockList = List<ProfitsBlockDto>();

    String walletId = AuthService.currentUser.currentWalletId;

    DateTime now = DateTime.now();
    DateTime firstDayOfCurrentMonth = DateTime(now.year, now.month, 1);

    int sixMonthsInDays = Constants.sixMonthsInDays;

    DateTime sixMonthsBefore =
        firstDayOfCurrentMonth.subtract(Duration(days: sixMonthsInDays));

    Timestamp startDate = Timestamp.fromDate(sixMonthsBefore);
    Timestamp endDate = Timestamp.fromDate(now);

    List<TransactionDto> transactions = await this
        .transactionsDao
        .getTransactionsByDateInterval(walletId, startDate, endDate);

    Map<DateTime, List<TransactionDto>> transactionsMap = groupBy(transactions,
        (kvp) => DateTime(kvp.transactionDate.year, kvp.transactionDate.month));

    var keys = transactionsMap.keys.toList().reversed;

    keys.forEach((element) {
      ProfitsBlockDto blockDto = ProfitsBlockDto();

      List<TransactionDto> transactionsOfMonth;

      double profitsAmount = 0;
      double spendsAmount = 0;
      double revenuesAmount = 0;

      if (transactionsMap.containsKey(element)) {
        transactionsOfMonth = transactionsMap[element];

        var spends =
            transactionsOfMonth.where((transaction) => transaction.amount < 0);

        var revenues =
            transactionsOfMonth.where((transaction) => transaction.amount > 0);

        spendsAmount = (spends.map((e) => e.amount)).fold(0, (a, b) => a + b);

        revenuesAmount =
            (revenues.map((e) => e.amount)).fold(0, (a, b) => a + b);

        profitsAmount = (revenuesAmount + spendsAmount);
      }

      blockDto.blockDate = element;
      blockDto.profit = profitsAmount;
      blockDto.revenue = revenuesAmount;
      blockDto.spends = spendsAmount;

      profitsBlockList.add(blockDto);
    });
    return profitsBlockList;
  }

  Future<bool> saveNewRevenue(NewRevenueForm form) async {
    bool success = false;

    success = await this.transactionsDao.saveNewRevenue(form);

    return success;
  }
}

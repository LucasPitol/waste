import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:waste_app/db/transactions_dao.dart';
import 'package:waste_app/models/dtos/spend_by_month_dto.dart';
import 'package:waste_app/models/dtos/spend_item_dto.dart';
import 'package:waste_app/models/dtos/transaction_block_dto.dart';
import 'package:waste_app/models/dtos/transaction_dto.dart';
import 'package:waste_app/models/forms/edit_waste_form.dart';
import 'package:waste_app/models/forms/new_revenue_form.dart';
import 'package:waste_app/models/forms/new_waste_form.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/services/smart_error_service.dart';

import 'auth_service.dart';
import 'spending_categories_service.dart';

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
      EditWasteForm form, String previousCategoryId) async {
    bool success = false;

    success = await this.transactionsDao.updateWaste(form);

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

  Future<bool> deleteWaste(String transactionId, String spendCategoryId) async {
    bool success = false;

    success = await this.transactionsDao.deleteWaste(transactionId);

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

    var spends = await this.transactionsDao.getSpendsByWalletId(walletId);

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

  Future<List<TransactionBlockDto>> getTransactionsByWalletId(String walletId) async {
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

  Future<bool> saveNewRevenue(NewRevenueForm form) async {
    bool success = false;

    success = await this.transactionsDao.saveNewRevenue(form);

    return success;
  }
}

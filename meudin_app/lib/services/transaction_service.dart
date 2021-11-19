import 'package:meudin_app/models/dtos/overview_page_dto.dart';
import 'package:meudin_app/models/forms/new_revenue_form.dart';
import 'package:meudin_app/models/forms/new_waste_form.dart';
import 'package:meudin_app/models/dtos/transaction_dto.dart';
import 'package:meudin_app/models/dtos/response_dto.dart';
import 'package:meudin_app/db/transaction_dao.dart';
import 'package:meudin_app/models/spending_category.dart';
import 'package:meudin_app/models/transaction.dart';

import 'spending_category_service.dart';

class TransactionService {
  late TransactionDao _transactionDao;
  late SpendingCategoryService _spendingCategoryService;

  TransactionService() {
    _transactionDao = TransactionDao();
    _spendingCategoryService = SpendingCategoryService();
  }

  Future<ResponseDto> getTransactionDtoList(
      String walletId, DateTime startDate, DateTime endDate) async {
    ResponseDto res = ResponseDto();
    List<TransactionDto> transactionDtoList = <TransactionDto>[];

    List<TransactionModel> transactions = await _transactionDao
        .getTransactionsByWalletIdAndDateInterval(walletId, startDate, endDate);

    for (var element in transactions) {
      TransactionDto transactionDto = TransactionDto(amount: 0);

      transactionDto.amount = element.amount;
      transactionDto.categoryId = element.categoryId;
      transactionDto.reason = element.reason;
      transactionDto.transactionDate = element.transactionDate;
      transactionDto.transactionId = element.id;

      transactionDtoList.add(transactionDto);
    }

    res.data = transactionDtoList;
    res.success = true;

    return res;
  }

  Future<ResponseDto> getOverviewPageDto(
      String walletId, DateTime startDate, DateTime endDate) async {
    ResponseDto res = ResponseDto();

    List<TransactionModel> transactions = await _transactionDao
        .getTransactionsByWalletIdAndDateInterval(walletId, startDate, endDate);

    ResponseDto spendingCategoriesRes =
        await _spendingCategoryService.getSpendingCategories();

    if (spendingCategoriesRes.success) {
      OverviewPageDto overViewPageDto = OverviewPageDto();

      List<SpendingCategory> categories = spendingCategoriesRes.data;

      double income = 0;
      double spends = 0;

      List<TransactionDto> transactionDtoList = [];

      Map<String, double> spendsByCategoryIdMap = <String, double>{};

      for (var element in transactions) {
        TransactionDto transactionDto = TransactionDto(amount: 0);

        double amount = element.amount;

        transactionDto.amount = amount;
        transactionDto.categoryId = element.categoryId;
        transactionDto.reason = element.reason;
        transactionDto.transactionDate = element.transactionDate;
        transactionDto.transactionId = element.id;

        transactionDtoList.add(transactionDto);

        if (amount >= 0) {
          income = income + amount;
        } else {
          spends = spends + amount;
        }

        String? categoryId = element.categoryId;

        // var category = categories
        //     .singleWhere((element) => categoryId == transactionDto.categoryId);

        if (categoryId != null && amount < 0) {
          if (spendsByCategoryIdMap.containsKey(categoryId)) {
            double? mapValue = spendsByCategoryIdMap[categoryId];

            mapValue = mapValue! + amount;

            spendsByCategoryIdMap.remove(categoryId);

            spendsByCategoryIdMap.putIfAbsent(categoryId, () => mapValue!);
          } else {
            spendsByCategoryIdMap.putIfAbsent(categoryId, () => amount);
          }
        }
      }

      Map<String, double> spendsByCategoryMap = <String, double>{};

      spendsByCategoryIdMap.forEach((key, value) {
        String categoryName =
            categories.singleWhere((element) => key == element.id).name;

        spendsByCategoryMap.putIfAbsent(categoryName, () => value);
      });

      var sortedKeys = spendsByCategoryMap.keys.toList(growable: true)
        ..sort((k1, k2) =>
            spendsByCategoryMap[k1]!.compareTo(spendsByCategoryMap[k2]!));

      Map<String, double> sortedMap = {
        for (var k in sortedKeys) k: spendsByCategoryMap[k]!
      };

      Map<String, double> sortedMapReduced = sortedMap;

      double totalOthers = 0.0;
      for (int i = 0; i < sortedKeys.length; i++) {
        if (i >= 3) {
          totalOthers = totalOthers + (sortedMapReduced[sortedKeys[i]]!);

          sortedMapReduced.remove(sortedKeys[i]);

          if (i == (sortedKeys.length - 1)) {
            String key = 'Demais';
            sortedMapReduced.putIfAbsent(key, () => totalOthers);
          }
        }
      }

      overViewPageDto.income = income;
      overViewPageDto.spends = spends;
      overViewPageDto.balance = (income - spends);
      overViewPageDto.spendsByCategoryMap = sortedMap;
      overViewPageDto.pieChartDataMap = sortedMapReduced;

      res.success = true;
      res.data = overViewPageDto;
    }

    return res;
  }

  Future<ResponseDto> saveNewRevenue(NewRevenueForm form) async {
    ResponseDto res = ResponseDto();

    String id = await _transactionDao.saveNewRevenue(form);

    res.success = true;
    res.data = id;

    return res;
  }

  Future<ResponseDto> saveNewWaste(NewWasteForm form) async {
    ResponseDto res = ResponseDto();

    String id = await _transactionDao.saveNewWaste(form);

    res.success = true;
    res.data = id;

    return res;
  }
}

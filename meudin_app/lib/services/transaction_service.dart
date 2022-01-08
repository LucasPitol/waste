import 'package:meudin_app/environment/environment.dart';
import 'package:meudin_app/models/dtos/new_revenue_dto.dart';
import 'package:meudin_app/models/dtos/new_waste_dto.dart';
import 'package:meudin_app/models/dtos/overview_page_dto.dart';
import 'package:meudin_app/models/forms/new_revenue_form.dart';
import 'package:meudin_app/models/forms/new_waste_form.dart';
import 'package:meudin_app/models/dtos/transaction_dto.dart';
import 'package:meudin_app/models/dtos/response_dto.dart';
import 'package:meudin_app/db/transaction_dao.dart';
import 'package:meudin_app/models/spending_category.dart';
import 'package:meudin_app/models/transaction.dart';
import 'package:http/http.dart' as http;
import 'package:meudin_app/utils/utils.dart';
import 'dart:convert';

import 'spending_category_service.dart';

class TransactionService {
  late TransactionDao _transactionDao;
  late SpendingCategoryService _spendingCategoryService;
  String apiUrl = Environment.apiUrl;
  Map<String, String> headersRequest = Environment.headersRequest;

  TransactionService() {
    _transactionDao = TransactionDao();
    _spendingCategoryService = SpendingCategoryService();
  }

  Future<ResponseDto> getTransactionDtoList(
      String walletId, DateTime startDate, DateTime endDate) async {
    Uri url =
        Uri.parse(this.apiUrl + 'getTransactionsByWalletIdAndDateInterval');

    var startDateStr = startDate.toString();
    var endDateStr = endDate.toString();

    var responseData = await http.post(
      url,
      headers: headersRequest,
      body: jsonEncode(
        {
          'walletId': walletId,
          'startDate': startDateStr,
          'endDate': endDateStr,
        },
      ),
    );

    ResponseDto res = ResponseDto(responseData);

    List<TransactionDto> transactionDtoList = [];

    if (res.success) {
      transactionDtoList = await _handleTransactionDto(res.data);
    }
    
    res.data = transactionDtoList;

    return res;
  }

  _handleTransactionDto(List<dynamic> transactionMapList) {
    List<TransactionDto> transactionDtoList = [];

    transactionMapList.forEach((element) {
      var transactionDto = TransactionDto.fromJson(element);

      transactionDtoList.add(transactionDto);
    });

    return transactionDtoList;
  }

  Future<ResponseDto> getOverviewPageDto(
      String walletId, DateTime startDate, DateTime endDate) async {
    Uri url = Uri.parse(this.apiUrl + 'getOverviewPageData');

    var responseData = await http.post(
      url,
      headers: headersRequest,
      body: jsonEncode(
        {
          'walletId': walletId,
          'startDate': startDate,
          'endDate': endDate,
        },
      ),
    );

    ResponseDto res = ResponseDto(responseData);

    return res;
  }

  Future<ResponseDto> saveNewRevenue(NewRevenueForm form) async {
    Uri url = Uri.parse(this.apiUrl + 'saveNewRevenue');

    var newRevenueDto = NewRevenueDto();

    newRevenueDto.reason = form.reason.text;
    newRevenueDto.payDay = form.payDay.toString();
    newRevenueDto.uid = form.uid;
    newRevenueDto.walletId = form.walletId;
    newRevenueDto.amount = Utils.convertStringFormToDouble(form.revenueValue.text);

    var newRevenueDtoJson = newRevenueDto.toJson();

    var responseData = await http.post(
      url,
      headers: headersRequest,
      body: jsonEncode(
        {
          'newRevenueDto': newRevenueDtoJson,
        },
      ),
    );

    ResponseDto res = ResponseDto(responseData);

    return res;
  }

  Future<ResponseDto> saveNewWaste(NewWasteForm form) async {
    Uri url = Uri.parse(this.apiUrl + 'saveNewWaste');

    var newWasteDto = NewWasteDto();

    newWasteDto.categoryId = form.categoryId;
    newWasteDto.reason = form.reason.text;
    newWasteDto.spendDate = form.spendDate.toString();
    newWasteDto.uid = form.uid;
    newWasteDto.walletId = form.walletId;

    double waste = Utils.convertStringFormToDouble(form.waste.text);
    double amount = (waste >= 0) ? waste * (-1) : waste;

    newWasteDto.waste = amount;

    var newWasteDtoJson = newWasteDto.toJson();

    var responseData = await http.post(
      url,
      headers: headersRequest,
      body: jsonEncode(
        {
          'newWasteDto': newWasteDtoJson,
        },
      ),
    );

    ResponseDto res = ResponseDto(responseData);

    return res;
  }
}

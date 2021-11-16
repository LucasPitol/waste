import 'package:meudin_app/db/transaction_dao.dart';
import 'package:meudin_app/models/dtos/response_dto.dart';
import 'package:meudin_app/models/dtos/transaction_dto.dart';
import 'package:meudin_app/models/forms/new_revenue_form.dart';
import 'package:meudin_app/models/forms/new_waste_form.dart';
import 'package:meudin_app/models/transaction.dart';

class TransactionService {
  late TransactionDao _transactionDao;

  TransactionService() {
    _transactionDao = TransactionDao();
  }

  Future<ResponseDto> getTransactionDtoList(
      String walletId, DateTime startDate, DateTime endDate) async {
    ResponseDto res = ResponseDto();
    List<TransactionDto> transactionDtoList = <TransactionDto>[];

    List<TransactionModel> transactions = await _transactionDao
        .getTransactionsByWalletIdAndDateInterval(walletId, startDate, endDate);

    for (var element in transactions) {
      TransactionDto transactionDto = TransactionDto();

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

import 'package:meudin_app/db/transaction_dao.dart';
import 'package:meudin_app/models/dtos/response_dto.dart';
import 'package:meudin_app/models/forms/new_revenue_form.dart';
import 'package:meudin_app/models/forms/new_waste_form.dart';

class TransactionService {
  late TransactionDao _transactionDao;

  TransactionService() {
    _transactionDao = TransactionDao();
  }

  Future<ResponseDto> saveNewRevenue(NewRevenueForm form) async {
    ResponseDto res = ResponseDto();

    String id = await _transactionDao.saveNewRevenue(form);

    res.success = true;
    res.data = id;

    return res;
  }

  Future<ResponseDto> savaNewWaste(NewWasteForm form) async {
    ResponseDto res = ResponseDto();

    String id = await _transactionDao.saveNewWaste(form);

    res.success = true;
    res.data = id;

    return res;
  }
}

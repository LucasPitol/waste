import 'package:meudin_app/db/spending_category_dao.dart';
import 'package:meudin_app/models/dtos/response_dto.dart';
import 'package:meudin_app/models/spending_category.dart';

class SpendingCategoryService {
  late SpendingCategoryDao _spendingCategoryDao;

  SpendingCategoryService() {
    _spendingCategoryDao = SpendingCategoryDao();
  }

  Future<ResponseDto> getSpendingCategories() async {
    ResponseDto res = ResponseDto();

    List<SpendingCategory> spendingCategories = await _spendingCategoryDao.getSpendingCategories();

    spendingCategories.sort((a, b) => a.name.compareTo(b.name));

    res.success = true;
    res.data = spendingCategories;

    return res;
  }
}
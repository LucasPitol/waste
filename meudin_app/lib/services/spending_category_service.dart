import 'package:meudin_app/db/spending_category_dao.dart';
import 'package:meudin_app/environment/environment.dart';
import 'package:meudin_app/models/dtos/response_dto.dart';
import 'package:meudin_app/models/spending_category.dart';
import 'package:http/http.dart' as http;

class SpendingCategoryService {
  late SpendingCategoryDao _spendingCategoryDao;
  String apiUrl = Environment.apiUrl;
  Map<String, String> headersRequest = Environment.headersRequest;

  SpendingCategoryService() {
    _spendingCategoryDao = SpendingCategoryDao();
  }

  Future<ResponseDto> getSpendingCategories() async {
    Uri url = Uri.parse(this.apiUrl + 'getSpendingCategories');

    var responseData = await http.post(
      url,
      headers: headersRequest,
      // body: jsonEncode(
      //   {
      //     'memberMail': memberMail,
      //     'wallet': wallet,
      //     'members': members,
      //   },
      // ),
    );

    ResponseDto res = ResponseDto(responseData);

    // TODO: implementar logica na API
    // List<SpendingCategory> spendingCategories =
    //     await _spendingCategoryDao.getSpendingCategories();

    // spendingCategories.sort((a, b) => a.name.compareTo(b.name));

    // res.success = true;
    // res.data = spendingCategories;

    return res;
  }
}

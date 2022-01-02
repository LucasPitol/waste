import 'package:meudin_app/environment/environment.dart';
import 'package:meudin_app/models/dtos/response_dto.dart';
import 'package:meudin_app/models/spending_category.dart';
import 'package:http/http.dart' as http;

class SpendingCategoryService {
  String apiUrl = Environment.apiUrl;
  Map<String, String> headersRequest = Environment.headersRequest;

  SpendingCategoryService() {
  }

  Future<ResponseDto> getSpendingCategories() async {
    Uri url = Uri.parse(this.apiUrl + 'getSpendingCategories');

    var responseData = await http.post(
      url,
      headers: headersRequest,
    );

    ResponseDto res = ResponseDto(responseData);

    if (res.success) {
      List<SpendingCategory> spendingCategoryList =
          await _handleSpendingCategories(res.data);
      res.data = spendingCategoryList;
    }

    return res;
  }

  _handleSpendingCategories(List<dynamic> spendingCategoryMapList) {
    List<SpendingCategory> spendingCategoryList = [];

    spendingCategoryMapList.forEach((element) {
      print(element);
      var spendingCatrgory = SpendingCategory.fromJson(element);

      spendingCategoryList.add(spendingCatrgory);
    });

    return spendingCategoryList;
  }
}

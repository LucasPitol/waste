import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meudin_ai_app/environment/environment.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/services/user_service.dart';

class SpendingCategoryService {
  String apiUrl = Environment.apiUrl;
  late UserService _userService;

  SpendingCategoryService() {
    _userService = UserService();
  }

  Future<ResponseDto> getSpendingCategories() async {
    final user = _userService.getCurrentUser();
    final authToken = user?.token;
    final url = Uri.parse('${apiUrl}getSpendingCategories');

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final response = await http.get(url, headers: headers);
    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));
    return responseDto;
  }
}

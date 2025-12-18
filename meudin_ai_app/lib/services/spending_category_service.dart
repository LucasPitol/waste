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
    // Este endpoint é público - não requer autenticação
    final url = Uri.parse('${apiUrl}spending-categories');

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);
    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));
    return responseDto;
  }
}

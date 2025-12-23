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

    try {
      final response = await http.get(url, headers: headers);
      
      // Verifica se a resposta é bem-sucedida
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Tenta fazer parse do JSON apenas se o body não estiver vazio
        if (response.body.isNotEmpty) {
          try {
            ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));
            return responseDto;
          } catch (e) {
            // Se não conseguir fazer parse do JSON, retorna erro
            return ResponseDto(
              success: false,
              errorMessage: 'Erro ao processar resposta: $e',
            );
          }
        } else {
          return ResponseDto(
            success: false,
            errorMessage: 'Resposta vazia do servidor',
          );
        }
      } else {
        // Resposta HTTP com erro (404, 500, etc)
        return ResponseDto(
          success: false,
          errorMessage: 'Erro ao buscar categorias: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      // Erro de rede ou outro erro
      return ResponseDto(
        success: false,
        errorMessage: 'Erro na requisição: $e',
      );
    }
  }
}

import 'dart:convert';
import 'package:meudin_ai_app/environment/environment.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/services/http_client.dart';
import 'package:meudin_ai_app/services/user_service.dart';

class SupportService {
  String apiUrl = Environment.apiUrl;

  Future<ResponseDto> contactSupport({
    required String message,
    String? walletId,
    required String platform,
    required String appVersion,
  }) async {
    final url = Uri.parse('${apiUrl}support/contact');

    final body = jsonEncode({
      'message': message,
      if (walletId != null && walletId.isNotEmpty) 'walletId': walletId,
      'platform': platform,
      'appVersion': appVersion,
    });

    final headers = UserService.getAuthHeaders();

    return await HttpClient.post(
      url,
      headers: headers,
      body: body,
    );
  }
}


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meudin_ai_app/services/http_interceptor.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';

/// Cliente HTTP com interceptor automático para tratamento de 401
class HttpClient {
  /// GET request com tratamento automático de erros
  static Future<ResponseDto> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await HttpInterceptor.get(url, headers: headers);
      return ResponseDto.fromJson(jsonDecode(response.body));
    } catch (e) {
      return ResponseDto(
        success: false,
        errorMessage: 'Erro na requisição: $e',
      );
    }
  }

  /// POST request com tratamento automático de erros
  static Future<ResponseDto> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await HttpInterceptor.post(
        url,
        headers: headers,
        body: body,
      );
      return ResponseDto.fromJson(jsonDecode(response.body));
    } catch (e) {
      return ResponseDto(
        success: false,
        errorMessage: 'Erro na requisição: $e',
      );
    }
  }

  /// PUT request com tratamento automático de erros
  static Future<ResponseDto> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await HttpInterceptor.put(
        url,
        headers: headers,
        body: body,
      );
      return ResponseDto.fromJson(jsonDecode(response.body));
    } catch (e) {
      return ResponseDto(
        success: false,
        errorMessage: 'Erro na requisição: $e',
      );
    }
  }

  /// DELETE request com tratamento automático de erros
  static Future<ResponseDto> delete(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await HttpInterceptor.delete(url, headers: headers);
      return ResponseDto.fromJson(jsonDecode(response.body));
    } catch (e) {
      return ResponseDto(
        success: false,
        errorMessage: 'Erro na requisição: $e',
      );
    }
  }

  /// Raw GET request (retorna http.Response diretamente)
  static Future<http.Response> getRaw(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    return await HttpInterceptor.get(url, headers: headers);
  }

  /// Raw POST request (retorna http.Response diretamente)
  static Future<http.Response> postRaw(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return await HttpInterceptor.post(url, headers: headers, body: body);
  }
}


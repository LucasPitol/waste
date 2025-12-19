import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/services/session_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';

/// HTTP Interceptor para tratar erros 401 e renovar tokens automaticamente
class HttpInterceptor {
  static bool _isRefreshing = false;
  static final List<Function> _requestsQueue = [];

  /// Faz uma requisição HTTP com tratamento automático de 401
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final response = await http.get(url, headers: headers);
    return await _handleResponse(response, () => http.get(url, headers: headers));
  }

  /// Faz uma requisição POST com tratamento automático de 401
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await http.post(url, headers: headers, body: body);
    return await _handleResponse(
      response,
      () => http.post(url, headers: headers, body: body),
    );
  }

  /// Faz uma requisição PUT com tratamento automático de 401
  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final response = await http.put(url, headers: headers, body: body);
    return await _handleResponse(
      response,
      () => http.put(url, headers: headers, body: body),
    );
  }

  /// Faz uma requisição DELETE com tratamento automático de 401
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final response = await http.delete(url, headers: headers);
    return await _handleResponse(
      response,
      () => http.delete(url, headers: headers),
    );
  }

  /// Trata a resposta HTTP e intercepta erros 401
  static Future<http.Response> _handleResponse(
    http.Response response,
    Future<http.Response> Function() retryRequest,
  ) async {
    // Se não for 401, retornar resposta normalmente
    if (response.statusCode != 401) {
      return response;
    }

    // Tentar parsear o erro
    try {
      final errorData = jsonDecode(response.body);
      final errorCode = errorData['code'] as String?;

      // Se o token expirou, tentar renovar
      if (errorCode == 'TOKEN_EXPIRED') {
        return await _handleTokenExpired(retryRequest);
      }

      // Token inválido ou sem token - redirecionar para login
      if (errorCode == 'INVALID_TOKEN' || errorCode == 'UNAUTHORIZED') {
        await _handleUnauthorized();
        return response;
      }
    } catch (e) {
      // Se não conseguir parsear, tratar como não autorizado
      await _handleUnauthorized();
    }

    return response;
  }

  /// Trata token expirado - tenta renovar e repetir a requisição
  static Future<http.Response> _handleTokenExpired(
    Future<http.Response> Function() retryRequest,
  ) async {
    // Se já está renovando, adicionar à fila
    if (_isRefreshing) {
      return await _addToQueue(retryRequest);
    }

    _isRefreshing = true;

    try {
      // Tentar renovar o token
      final userService = UserService();
      final refreshResponse = await userService.refreshToken();

      if (refreshResponse.success) {
        // Token renovado com sucesso - processar fila e repetir requisição
        _isRefreshing = false;
        await _processQueue();
        return await retryRequest();
      } else {
        // Falha ao renovar - redirecionar para login
        _isRefreshing = false;
        await _handleUnauthorized();
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      _isRefreshing = false;
      await _handleUnauthorized();
      throw Exception('Error refreshing token: $e');
    }
  }

  /// Adiciona requisição à fila enquanto o token está sendo renovado
  static Future<http.Response> _addToQueue(
    Future<http.Response> Function() retryRequest,
  ) async {
    // Aguardar até que o token seja renovado
    while (_isRefreshing) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Tentar novamente após renovação
    return await retryRequest();
  }

  /// Processa todas as requisições na fila após renovação do token
  static Future<void> _processQueue() async {
    for (var request in _requestsQueue) {
      try {
        await request();
      } catch (e) {
        // Silent error handling
      }
    }
    _requestsQueue.clear();
  }

  /// Trata erro de não autorizado - limpa sessão e redireciona para login
  static Future<void> _handleUnauthorized() async {
    try {
      // Limpar sessão local
      await SessionService.logout();

      // Redirecionar para login (apenas se não estiver já na tela de login)
      if (Get.currentRoute != AppRoutes.signInRoute) {
        Get.offAllNamed(AppRoutes.signInRoute);
      }
    } catch (e) {
      // Silent error handling
    }
  }

  /// Verifica se o token está próximo de expirar e renova preventivamente
  static Future<void> refreshTokenIfNeeded() async {
    // TODO: Implementar lógica para verificar expiração do token
    // Por enquanto, deixar para renovar apenas quando receber 401
  }
}


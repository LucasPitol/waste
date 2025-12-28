import 'dart:convert';
import 'package:meudin_ai_app/environment/environment.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/models/user_subscription.dart';
import 'package:meudin_ai_app/services/http_client.dart';
import 'package:meudin_ai_app/services/user_service.dart';

/// Serviço para gerenciar assinaturas e planos
class SubscriptionService {
  final String apiUrl = Environment.apiUrl;

  /// Obtém informações da assinatura do usuário autenticado
  Future<ResponseDto> getMySubscription() async {
    final user = UserService.currentUser;
    if (user?.token == null || user!.token!.isEmpty) {
      return ResponseDto(
        success: false,
        errorMessage: 'Usuário não autenticado',
      );
    }

    final url = Uri.parse('${apiUrl}subscriptions/me/subscription');
    final headers = UserService.getAuthHeaders();

    try {
      final response = await HttpClient.get(url, headers: headers);

      if (response.success && response.data != null) {
        final userSubscription = UserSubscription.fromJson(response.data);
        return ResponseDto(
          success: true,
          data: userSubscription.toJson(),
        );
      }

      return ResponseDto(
        success: false,
        errorMessage: response.errorMessage ?? 'Erro ao buscar assinatura',
      );
    } catch (e) {
      return ResponseDto(
        success: false,
        errorMessage: 'Erro na requisição: $e',
      );
    }
  }

  /// Gera URL de SSO para acessar a página de gerenciamento de assinatura
  /// Retorna a URL completa com token de SSO para abrir no browser
  /// 
  /// Fluxo:
  /// 1. App envia access_token do Supabase no header
  /// 2. API valida o token no Supabase
  /// 3. API gera JWT curto (5 min) com aud = billing_web
  /// 4. API retorna URL completa: https://billing.meudin.app/sso?token=xyz
  Future<ResponseDto> getSsoUrl() async {
    final user = UserService.currentUser;
    if (user?.token == null || user!.token!.isEmpty) {
      return ResponseDto(
        success: false,
        errorMessage: 'Usuário não autenticado',
      );
    }

    final url = Uri.parse('${apiUrl}auth/sso');
    final headers = UserService.getAuthHeaders();

    try {
      // POST /api/auth/sso
      // Body não é necessário, token vem no header Authorization
      final response = await HttpClient.post(url, headers: headers);

      if (response.success && response.data != null) {
        // Response esperado: { "success": true, "data": { "sso_url": "...", "token": "...", "expires_in": 300 } }
        if (response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          
          // Extrair sso_url do response
          if (data['sso_url'] != null) {
            return ResponseDto(
              success: true,
              data: data['sso_url'],
            );
          }
          
          // Fallback: se vier com nome diferente
          if (data['ssoUrl'] != null) {
            return ResponseDto(
              success: true,
              data: data['ssoUrl'],
            );
          }
        }
        
        // Se retornar URL diretamente como string
        if (response.data is String) {
          return ResponseDto(
            success: true,
            data: response.data,
          );
        }
      }

      // Se não conseguir extrair a URL, retornar erro
      return ResponseDto(
        success: false,
        errorMessage: response.errorMessage ?? 'Erro ao gerar URL de SSO',
      );
    } catch (e) {
      return ResponseDto(
        success: false,
        errorMessage: 'Erro ao gerar URL de SSO: $e',
      );
    }
  }
}


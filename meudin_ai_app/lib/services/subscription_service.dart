import 'dart:convert';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meudin_ai_app/environment/environment.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/models/user_subscription.dart';
import 'package:meudin_ai_app/services/http_client.dart';
import 'package:meudin_ai_app/services/http_interceptor.dart';
import 'package:meudin_ai_app/services/user_service.dart';

/// Serviço para gerenciar assinaturas e planos
class SubscriptionService {
  final String apiUrl = Environment.apiUrl;

  /// Obtém o plano atual do usuário (endpoint leve)
  /// GET /api/subscriptions/me/plan
  Future<PlanCode?> getCurrentPlan() async {
    final user = UserService.currentUser;
    if (user?.token == null || user!.token!.isEmpty) {
      return null;
    }

    final url = Uri.parse('${apiUrl}subscriptions/me/plan');
    final headers = UserService.getAuthHeaders();

    try {
      final response = await HttpClient.get(url, headers: headers);
      if (response.success && response.data != null && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final planCode = data['plan_code'] as String?;
        return planCode != null ? PlanCode.fromString(planCode) : null;
      }
    } catch (_) {}
    return null;
  }

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

  /// Valida compra in-app com o backend (receipt Apple ou token Google)
  /// POST /api/subscriptions/validate-purchase
  Future<bool> validatePurchase({
    required PurchaseDetails purchase,
    required String productId,
    required String packageName,
  }) async {
    final user = UserService.currentUser;
    if (user?.token == null || user!.token!.isEmpty) {
      return false;
    }

    final url = Uri.parse('${apiUrl}subscriptions/validate-purchase');
    final headers = UserService.getAuthHeaders();

    Map<String, dynamic> body;
    final source = purchase.verificationData.source;

    if (source == 'app_store') {
      body = {
        'provider': 'apple',
        'receipt': purchase.verificationData.serverVerificationData,
      };
    } else if (source == 'play_store') {
      final token = _extractGooglePurchaseToken(
        purchase.verificationData.serverVerificationData,
      );
      if (token == null) return false;

      body = {
        'provider': 'google',
        'package_name': packageName,
        'product_id': productId,
        'purchase_token': token,
      };
    } else {
      return false;
    }

    try {
      final response = await HttpInterceptor.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        return false;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Valida assinatura com receipt Apple (app start ou restore)
  /// POST /api/subscriptions/validate-purchase
  /// Retorna plan_code ou null
  Future<PlanCode?> validateReceipt(String receiptData) async {
    final user = UserService.currentUser;
    if (user?.token == null || user!.token!.isEmpty) return null;
    if (receiptData.isEmpty) return null;

    final url = Uri.parse('${apiUrl}subscriptions/validate-purchase');
    final headers = UserService.getAuthHeaders();
    final body = jsonEncode({
      'provider': 'apple',
      'receipt': receiptData,
    });

    try {
      final response = await HttpInterceptor.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] != true) return null;

      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      final planCodeStr = data['plan_code'] as String?;
      return planCodeStr != null ? PlanCode.fromString(planCodeStr) : null;
    } catch (_) {
      return null;
    }
  }

  /// Extrai purchase_token do serverVerificationData (Google)
  /// Pode ser JSON ou string pura
  String? _extractGooglePurchaseToken(String data) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map && decoded['purchaseToken'] != null) {
        return decoded['purchaseToken'] as String;
      }
    } catch (_) {
      // Se não for JSON, usar como token direto
    }
    return data.isNotEmpty ? data : null;
  }
}


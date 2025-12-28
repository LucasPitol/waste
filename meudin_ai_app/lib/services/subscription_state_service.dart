import 'package:meudin_ai_app/models/plan_limits.dart';
import 'package:meudin_ai_app/models/user_subscription.dart';
import 'package:meudin_ai_app/services/subscription_service.dart';
import 'package:meudin_ai_app/services/user_service.dart';

/// Serviço para gerenciar o estado da assinatura do usuário
/// Cacheia os dados da assinatura e fornece métodos para verificar limites
class SubscriptionStateService {
  static UserSubscription? _cachedSubscription;
  static DateTime? _lastFetch;
  static const Duration _cacheDuration = Duration(minutes: 5);

  final SubscriptionService _subscriptionService = SubscriptionService();

  /// Obtém a assinatura do usuário (com cache)
  Future<UserSubscription?> getSubscription({bool forceRefresh = false}) async {
    // Verificar se o cache ainda é válido
    if (!forceRefresh &&
        _cachedSubscription != null &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheDuration) {
      return _cachedSubscription;
    }

    // Buscar do servidor
    final response = await _subscriptionService.getMySubscription();

    if (response.success && response.data != null) {
      try {
        _cachedSubscription = UserSubscription.fromJson(response.data);
        _lastFetch = DateTime.now();
        return _cachedSubscription;
      } catch (e) {
        // Erro ao parsear, retornar null
        return null;
      }
    }

    // Se falhou, retornar cache antigo se existir
    return _cachedSubscription;
  }

  /// Limpa o cache (útil após logout ou mudança de assinatura)
  static void clearCache() {
    _cachedSubscription = null;
    _lastFetch = null;
  }

  /// Obtém os limites do plano do dono da carteira atual
  /// Retorna null se não conseguir determinar
  Future<PlanLimits?> getCurrentWalletLimits() async {
    final user = UserService.currentUser;
    if (user == null || user.currentWalletId.isEmpty) {
      return null;
    }

    // Buscar a carteira atual
    final currentWallet = user.walletList.firstWhere(
      (w) => w.id == user.currentWalletId,
      orElse: () => user.walletList.isNotEmpty ? user.walletList.first : throw StateError('No wallet'),
    );

    // Se o usuário é o dono, usar seus limites
    if (currentWallet.ownerId == user.id) {
      final subscription = await getSubscription();
      return subscription?.limits;
    }

    // Se não é o dono, buscar limites do dono da carteira
    // TODO: Implementar endpoint no backend para buscar limites do dono
    // Por enquanto, retornar limites do usuário atual (backend deve fazer isso)
    final subscription = await getSubscription();
    return subscription?.limits;
  }

  /// Verifica se o usuário pode criar mais carteiras
  Future<bool> canCreateWallet() async {
    final user = UserService.currentUser;
    if (user == null) return false;

    final subscription = await getSubscription();
    if (subscription == null) return false;

    // Contar carteiras do usuário
    final userWalletsCount = user.walletList.length;
    return userWalletsCount < subscription.limits.maxWallets;
  }

  /// Verifica se o usuário pode adicionar mais membros à carteira atual
  Future<bool> canAddMember() async {
    final limits = await getCurrentWalletLimits();
    if (limits == null) return false;

    // TODO: Buscar quantidade atual de membros da carteira
    // Por enquanto, assumir que pode (backend deve validar)
    return true;
  }

  /// Verifica se o histórico é ilimitado para a carteira atual
  Future<bool> hasUnlimitedHistory() async {
    final limits = await getCurrentWalletLimits();
    return limits?.hasUnlimitedHistory ?? false;
  }

  /// Obtém o número máximo de meses de histórico permitido
  /// Retorna null se for ilimitado
  Future<int?> getMaxHistoryMonths() async {
    final limits = await getCurrentWalletLimits();
    return limits?.historyMonths;
  }
}


/// Limites do plano de assinatura
class PlanLimits {
  final int maxWallets;
  final int maxMembersPerWallet;
  final int? historyMonths; // null = ilimitado
  final bool canExport;

  PlanLimits({
    required this.maxWallets,
    required this.maxMembersPerWallet,
    this.historyMonths,
    required this.canExport,
  });

  factory PlanLimits.fromJson(Map<String, dynamic> json) {
    return PlanLimits(
      maxWallets: json['max_wallets'] ?? 2,
      maxMembersPerWallet: json['max_members_per_wallet'] ?? 1,
      historyMonths: json['history_months'],
      canExport: json['can_export'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_wallets': maxWallets,
      'max_members_per_wallet': maxMembersPerWallet,
      'history_months': historyMonths,
      'can_export': canExport,
    };
  }

  /// Verifica se o histórico é ilimitado
  bool get hasUnlimitedHistory => historyMonths == null;

  /// Limites por plano (fonte da verdade)
  static PlanLimits forPlanCode(String planCode) {
    switch (planCode.toLowerCase()) {
      case 'plus':
        return PlanLimits(
          maxWallets: 5,
          maxMembersPerWallet: 5,
          historyMonths: 12,
          canExport: false,
        );
      case 'pro':
        return PlanLimits(
          maxWallets: 20,
          maxMembersPerWallet: 20,
          historyMonths: null,
          canExport: true,
        );
      case 'free':
      default:
        return PlanLimits(
          maxWallets: 2,
          maxMembersPerWallet: 2,
          historyMonths: 3,
          canExport: false,
        );
    }
  }
}


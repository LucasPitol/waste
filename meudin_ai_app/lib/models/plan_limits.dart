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
}


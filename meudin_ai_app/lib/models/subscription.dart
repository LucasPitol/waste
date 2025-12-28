/// Modelo de assinatura do usuário
class Subscription {
  final String id;
  final SubscriptionStatus status;
  final String? provider; // 'asaas' | 'apple' | 'google'
  final DateTime? startedAt;
  final DateTime? expiresAt;

  Subscription({
    required this.id,
    required this.status,
    this.provider,
    this.startedAt,
    this.expiresAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      status: SubscriptionStatus.fromString(json['status'] ?? 'expired'),
      provider: json['provider'],
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.value,
      'provider': provider,
      'startedAt': startedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  bool get isActive => status == SubscriptionStatus.active;
  bool get isPending => status == SubscriptionStatus.pending;
  bool get isExpired => status == SubscriptionStatus.expired;
}

/// Status da assinatura
enum SubscriptionStatus {
  pending,
  active,
  pastDue,
  canceled,
  expired;

  String get value {
    switch (this) {
      case SubscriptionStatus.pending:
        return 'pending';
      case SubscriptionStatus.active:
        return 'active';
      case SubscriptionStatus.pastDue:
        return 'past_due';
      case SubscriptionStatus.canceled:
        return 'canceled';
      case SubscriptionStatus.expired:
        return 'expired';
    }
  }

  static SubscriptionStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return SubscriptionStatus.pending;
      case 'active':
        return SubscriptionStatus.active;
      case 'past_due':
        return SubscriptionStatus.pastDue;
      case 'canceled':
        return SubscriptionStatus.canceled;
      case 'expired':
        return SubscriptionStatus.expired;
      default:
        return SubscriptionStatus.expired;
    }
  }
}


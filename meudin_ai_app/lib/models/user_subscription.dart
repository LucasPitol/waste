import 'package:meudin_ai_app/models/subscription.dart';
import 'package:meudin_ai_app/models/plan_limits.dart';

/// Informações completas de assinatura do usuário
class UserSubscription {
  final PlanCode plan;
  final PlanLimits limits;
  final Subscription? subscription;

  UserSubscription({
    required this.plan,
    required this.limits,
    this.subscription,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      plan: PlanCode.fromString(json['plan'] ?? 'free'),
      limits: PlanLimits.fromJson(json['limits'] ?? {}),
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan.value,
      'limits': limits.toJson(),
      'subscription': subscription?.toJson(),
    };
  }

  /// Verifica se o usuário tem plano premium (Plus ou Pro)
  bool get isPremium => plan != PlanCode.free;

  /// Verifica se o usuário tem plano Pro
  bool get isPro => plan == PlanCode.pro;

  /// Verifica se o usuário tem plano Plus
  bool get isPlus => plan == PlanCode.plus;
}

/// Código do plano
enum PlanCode {
  free,
  plus,
  pro;

  String get value {
    switch (this) {
      case PlanCode.free:
        return 'free';
      case PlanCode.plus:
        return 'plus';
      case PlanCode.pro:
        return 'pro';
    }
  }

  String get displayName {
    switch (this) {
      case PlanCode.free:
        return 'Start';
      case PlanCode.plus:
        return 'Plus';
      case PlanCode.pro:
        return 'Pro';
    }
  }

  static PlanCode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'plus':
        return PlanCode.plus;
      case 'pro':
        return PlanCode.pro;
      case 'free':
      default:
        return PlanCode.free;
    }
  }
}


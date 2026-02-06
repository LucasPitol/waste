import 'package:get/get.dart';
import 'package:meudin_ai_app/models/plan_limits.dart';

enum PlanCode { free, plus, pro }

/// Dados de um plano de assinatura para exibição no paywall
class PlanDisplay {
  final PlanCode code;
  final String name;
  final String price;
  final String? cycle;
  final PlanLimits limits;

  const PlanDisplay({
    required this.code,
    required this.name,
    required this.price,
    this.cycle,
    required this.limits,
  });
}

class PlansPageController extends GetxController {
  static final List<PlanDisplay> plans = [
    PlanDisplay(
      code: PlanCode.free,
      name: 'Start',
      price: 'R\$ 0',
      cycle: null,
      limits: PlanLimits(
        maxWallets: 2,
        maxMembersPerWallet: 2,
        historyMonths: 3,
        canExport: false,
      ),
    ),
    PlanDisplay(
      code: PlanCode.plus,
      name: 'Plus',
      price: 'R\$ 7,90',
      cycle: 'mensal',
      limits: PlanLimits(
        maxWallets: 5,
        maxMembersPerWallet: 5,
        historyMonths: 12,
        canExport: false,
      ),
    ),
    PlanDisplay(
      code: PlanCode.pro,
      name: 'Pro',
      price: 'R\$ 12,90',
      cycle: 'mensal',
      limits: PlanLimits(
        maxWallets: 20,
        maxMembersPerWallet: 20,
        historyMonths: null,
        canExport: true,
      ),
    ),
  ];

  static PlanDisplay get plusPlan =>
      plans.firstWhere((p) => p.code == PlanCode.plus);

  static PlanDisplay get proPlan =>
      plans.firstWhere((p) => p.code == PlanCode.pro);

  /// Benefícios em linguagem humana (Plus hero)
  static const List<String> plusBenefits = [
    'Até 5 carteiras',
    'Até 5 membros por carteira',
    'Histórico financeiro de até 12 meses',
  ];

  /// Benefícios em linguagem humana (Pro)
  static const List<String> proBenefits = [
    'Até 20 carteiras ativas',
    'Até 20 membros por carteira',
    'Histórico financeiro ilimitado',
    'Ideal para famílias grandes e negócios',
  ];

  void onSubscribe(PlanDisplay plan) {
    // TODO: Integrar com IAP (in-app purchase)
    Get.back();
  }
}

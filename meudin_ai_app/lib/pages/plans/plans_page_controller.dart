import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/models/plan_limits.dart';
import 'package:meudin_ai_app/services/iap_service.dart';
import 'package:meudin_ai_app/services/plan_state_controller.dart';

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

  final IapService _iapService = IapService();

  bool _isPurchasing = false;
  bool get isPurchasing => _isPurchasing;

  Future<void> onSubscribe(PlanDisplay plan) async {
    if (_isPurchasing) return;

    _isPurchasing = true;
    update();

    try {
      final result = await _iapService.purchase(plan);

      switch (result) {
        case IapPurchaseResult.success:
          if (Get.isRegistered<PlanStateController>()) {
            await Get.find<PlanStateController>().refreshPlan();
          }
          Get.back(result: true);
          Get.snackbar(
            'Assinatura ativa',
            'Seu plano ${plan.name} foi ativado com sucesso.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.isDarkMode ? null : const Color(0xFFAC6CFF).withValues(alpha: 0.15),
            colorText: Get.isDarkMode ? null : const Color(0xFF212121),
          );
          break;

        case IapPurchaseResult.canceled:
          Get.snackbar(
            'Compra cancelada',
            'Nenhuma cobrança foi realizada.',
            snackPosition: SnackPosition.BOTTOM,
          );
          break;

        case IapPurchaseResult.error:
          Get.snackbar(
            'Erro na compra',
            'Não foi possível processar. Tente novamente ou entre em contato com o suporte.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.isDarkMode ? null : Colors.red.shade100,
          );
          break;

        case IapPurchaseResult.pending:
          Get.snackbar(
            'Pagamento pendente',
            'Aguardando confirmação do pagamento.',
            snackPosition: SnackPosition.BOTTOM,
          );
          break;
      }
    } catch (e) {
      _isPurchasing = false;
      update();
      Get.snackbar(
        'Erro',
        'Tente novamente ou entre em contato com o suporte.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isPurchasing = false;
      update();
    }
  }

  /// Restaurar compras (reinstalação ou troca de dispositivo)
  Future<void> onRestorePurchases() async {
    if (_isPurchasing) return;

    _isPurchasing = true;
    update();

    try {
      final result = await _iapService.restorePurchases();

      switch (result) {
        case IapPurchaseResult.success:
          if (Get.isRegistered<PlanStateController>()) {
            await Get.find<PlanStateController>().refreshPlan();
          }
          Get.back(result: true);
          Get.snackbar(
            'Compra restaurada',
            'Seu plano foi restaurado com sucesso.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.isDarkMode
                ? null
                : const Color(0xFFAC6CFF).withValues(alpha: 0.15),
          );
          break;

        case IapPurchaseResult.canceled:
          Get.snackbar(
            'Restauração cancelada',
            'Nenhuma compra anterior encontrada.',
            snackPosition: SnackPosition.BOTTOM,
          );
          break;

        case IapPurchaseResult.error:
          Get.snackbar(
            'Erro na restauração',
            'Não foi possível restaurar. Tente novamente.',
            snackPosition: SnackPosition.BOTTOM,
          );
          break;

        case IapPurchaseResult.pending:
          Get.snackbar(
            'Processando...',
            'Aguardando confirmação.',
            snackPosition: SnackPosition.BOTTOM,
          );
          break;
      }
    } finally {
      _isPurchasing = false;
      update();
    }
  }

  @override
  void onClose() {
    _iapService.dispose();
    super.onClose();
  }
}

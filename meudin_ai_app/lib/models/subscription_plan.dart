class SubscriptionPlan {
  final String id;
  final String name;
  final String keyBenefit; // Benefício principal (máx 2 linhas)
  final bool isCurrent; // Se é o plano atual do usuário

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.keyBenefit,
    this.isCurrent = false,
  });

  // Planos padrão para demonstração
  static List<SubscriptionPlan> getDefaultPlans() {
    return [
      SubscriptionPlan(
        id: 'starter',
        name: 'Plano Free',
        keyBenefit: 'Gestão básica de finanças pessoais',
        isCurrent: true,
      ),
      SubscriptionPlan(
        id: 'premium',
        name: 'Plano Premium',
        keyBenefit: 'Mais carteiras e histórico anual completo',
        isCurrent: false,
      ),
      SubscriptionPlan(
        id: 'business',
        name: 'Plano Empresarial',
        keyBenefit: 'Gestão avançada para pequenos negócios',
        isCurrent: false,
      ),
    ];
  }
}

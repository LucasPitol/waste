# Implementação de Monetização - App Flutter

## Resumo

Implementação completa da feature de monetização no app Flutter, seguindo as diretrizes da documentação `billing.md`.

## Arquivos Criados

### Modelos
- `lib/models/subscription.dart` - Modelo de assinatura e status
- `lib/models/plan_limits.dart` - Limites do plano (carteiras, membros, histórico, exportação)
- `lib/models/user_subscription.dart` - Informações completas de assinatura do usuário

### Serviços
- `lib/services/subscription_service.dart` - Serviço para gerenciar assinaturas e SSO
- `lib/services/subscription_state_service.dart` - Gerenciamento de estado e cache de assinatura

### Componentes UI
- `lib/ui/subscription/manage_subscription_button.dart` - Botão "Gerenciar assinatura" com SSO
- `lib/ui/subscription/premium_badge.dart` - Badge para indicar recursos premium
- `lib/ui/subscription/premium_feature_wrapper.dart` - Wrapper para funcionalidades premium

## Funcionalidades Implementadas

### 1. Obtenção de Dados de Assinatura
- Endpoint: `GET /api/subscriptions/me/subscription`
- Retorna: plano atual, limites e status da assinatura
- Cache de 5 minutos para otimização

### 2. SSO para Página Web
- Botão "Gerenciar assinatura" abre browser externo
- **TODO**: Implementar endpoint `POST /api/auth/sso` no backend
- Por enquanto, abre URL base: `https://billing.meudin.app`

### 3. Validação de Limites
- **Criação de carteiras**: Valida limite antes de criar
- **Adição de membros**: Backend valida (frontend apenas UI)
- **Histórico**: Backend força limites no SQL (frontend apenas UI)

### 4. UI de Monetização
- Seção de assinatura na página de perfil
- Badge para recursos premium
- Wrapper para funcionalidades bloqueadas
- Botão neutro "Gerenciar assinatura" (sem preços, sem CTAs de compra)

## Regras Implementadas

### ✅ Permitido no App
- Indicar recursos exclusivos para assinantes
- Botão neutro: "Gerenciar assinatura"
- Badges e mensagens informativas

### ❌ Proibido no App
- Exibir preços
- Botões de compra diretos
- Mencionar meios de pagamento
- Comparativos de preços

## Integrações

### Páginas Atualizadas
- `lib/pages/profile/profile_page.dart` - Adicionada seção de assinatura
- `lib/pages/profile/profile_page_controller.dart` - Carrega dados de assinatura
- `lib/pages/new_wallet/new_wallet_page_controller.dart` - Valida limite antes de criar

### Próximos Passos (Backend)
1. Implementar endpoint `POST /api/auth/sso` que retorna URL com token
2. Endpoint deve gerar JWT temporário (5 min) para SSO web
3. Webhook do Asaas deve atualizar status da assinatura

## Uso dos Componentes

### Botão "Gerenciar Assinatura"
```dart
ManageSubscriptionButton(
  customText: 'Gerenciar assinatura', // opcional
  textColor: Styles.primaryColor,    // opcional
  fontSize: 14,                        // opcional
)
```

### Badge Premium
```dart
PremiumBadge(
  customText: 'Disponível para assinantes', // opcional
  padding: EdgeInsets.all(8),              // opcional
)
```

### Wrapper de Feature Premium
```dart
PremiumFeatureWrapper(
  userSubscription: subscription,
  requiresPremium: true, // true = Plus ou Pro, false = qualquer pago
  featureName: 'Exportação',
  child: YourFeatureWidget(),
)
```

### Verificar Limites
```dart
final subscriptionService = SubscriptionStateService();

// Verificar se pode criar carteira
final canCreate = await subscriptionService.canCreateWallet();

// Verificar se histórico é ilimitado
final unlimited = await subscriptionService.hasUnlimitedHistory();

// Obter limites da carteira atual
final limits = await subscriptionService.getCurrentWalletLimits();
```

## Notas Importantes

1. **Cache**: Dados de assinatura são cacheados por 5 minutos
2. **Limites por Carteira**: Limites são baseados no plano do **dono da carteira**
3. **SSO**: Endpoint de SSO precisa ser implementado no backend
4. **Validação Backend**: Frontend apenas valida para UX, backend é fonte da verdade

## Testes Recomendados

1. Usuário sem assinatura (plano Free)
2. Usuário com assinatura ativa (Plus/Pro)
3. Criação de carteira acima do limite
4. Abertura do botão "Gerenciar assinatura"
5. Alternância entre carteiras com donos diferentes


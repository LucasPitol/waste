# Implementação da Monetização – Meudin App

Este documento descreve como foi implementado o fluxo de assinatura, monetização e bloqueio de ações no app Flutter.

---

## 1. Visão geral

O Meudin possui três planos (**Free**, **Plus** e **Pro**) com monetização via in-app purchase (Apple e Google). Os limites de uso são aplicados no backend; o app detecta respostas de limite e exibe UX adequada (modal de limite com CTA para upgrade).

---

## 2. Arquitetura de arquivos

| Camada | Arquivos |
|--------|----------|
| **Modelos** | `lib/models/plan_limits.dart`, `lib/models/user_subscription.dart`, `lib/models/dtos/response_dto.dart` |
| **Serviços** | `lib/services/iap_service.dart`, `lib/services/subscription_service.dart`, `lib/services/subscription_state_service.dart`, `lib/services/plan_state_controller.dart`, `lib/services/receipt_storage_service.dart` |
| **UI** | `lib/pages/plans/plans_page.dart`, `lib/pages/plans/plans_page_controller.dart`, `lib/ui/joy_modal.dart` |
| **Fluxos de limite** | `lib/pages/new_wallet/new_wallet_page_controller.dart`, `lib/pages/add_member/add_member_page_controller.dart`, `lib/modules/home/home_module_controller.dart`, `lib/modules/insights/insights_module_controller.dart` |

---

## 3. Fluxo de assinatura (IAP)

### 3.1 Sequência

1. **Flutter inicia compra** – `IapService.purchase()` → `_iap.buyNonConsumable()`
2. **Loja confirma pagamento** – `purchaseStream` escuta `PurchaseStatus.purchased`
3. **App envia receipt/token à API** – `_validateAndComplete()` chama `SubscriptionService.validatePurchase()`
4. **Backend valida** – `POST /api/subscriptions/validate-purchase`
5. **App persiste receipt Apple** (MONO-FE-01) – `ReceiptStorageService.saveAppleReceipt()`
6. **App atualiza plano** – `SubscriptionStateService.clearCache()` + refetch implícito

### 3.2 Produtos IAP

```dart
// lib/services/iap_service.dart
IapProductIds.plus  // 'meudin_plus'
IapProductIds.pro   // 'meudin_pro'
```

### 3.3 Validação no backend

- **Apple:** `{ "provider": "apple", "receipt": "<base64>" }`
- **Google:** `{ "provider": "google", "package_name", "product_id", "purchase_token" }`

---

## 4. Validação do plano no app

### 4.1 Ao abrir o app (MONO-FE-02)

`PlanStateController.refreshPlan()` é chamado:

- **iOS:** Se houver receipt persistido, envia `POST /api/subscriptions/validate-purchase` com o receipt; usa `plan_code` retornado
- **Fallback:** `GET /api/subscriptions/me/plan` retorna `{ "plan_code": "free"|"plus"|"pro" }`

O plano é armazenado em `planCode` (GetX) e propagado para `SubscriptionStateService.updateFromPlanCode()`.

### 4.2 Receipt persistido (MONO-FE-01)

- **Persistência:** `ReceiptStorageService` usa `flutter_secure_storage` para salvar o receipt Apple após compra/restauração
- **Chave:** `apple_app_receipt`
- **Uso:** Validação on-demand ao abrir o app (iOS)
- **Limpeza:** `clearAppleReceipt()` no logout

---

## 5. Limites de plano (fonte da verdade no app)

`PlanLimits.forPlanCode()` em `lib/models/plan_limits.dart`:

| Plano | max_wallets | max_members_per_wallet | history_months | can_export |
|-------|-------------|------------------------|----------------|------------|
| Free | 2 | 2 | 3 | false |
| Plus | 5 | 5 | 12 | false |
| Pro | 20 | 20 | null (ilimitado) | true |

---

## 6. Bloqueio de ações e UX de limite

### 6.1 Modal de limite

`JoyModal.limitReachedBottomSheet()` em `lib/ui/joy_modal.dart`:

- Título e mensagem configuráveis
- CTA **"Fazer upgrade"** → navega para `/plans`
- Botão **"Fechar"** → fecha o modal

### 6.2 Detecção de erro de limite

Função `_isPlanLimitError(message)` (em NewWalletPageController e AddMemberPageController):

```dart
bool _isPlanLimitError(String message) {
  final lower = message.toLowerCase();
  return lower.contains('limite') || lower.contains('faça upgrade');
}
```

Usada para decidir se o erro da API deve abrir o modal de limite em vez do modal genérico de erro.

### 6.3 Casos de uso

#### POST /api/wallet – Criar carteira

| Momento | Comportamento |
|---------|----------------|
| **Client-side** | `SubscriptionStateService.canCreateWallet()` – verifica `walletList.length < maxWallets` |
| **API retorna 400** | Se `errorMsg` contiver "limite" ou "Faça upgrade" → `JoyModal.limitReachedBottomSheet()` |

**Arquivo:** `lib/pages/new_wallet/new_wallet_page_controller.dart`

#### POST /api/wallet/add-member – Adicionar membro

| Momento | Comportamento |
|---------|----------------|
| **API retorna 403/409** | Se `errorMsg` contiver "limite" ou "Faça upgrade" → `JoyModal.limitReachedBottomSheet()` |

**Arquivo:** `lib/pages/add_member/add_member_page_controller.dart`

#### GET /api/transaction e GET /api/transaction/overview

| Momento | Comportamento |
|---------|----------------|
| **API retorna 200** | Se `warningMessage` existir (intervalo ajustado por `history_months`) → `Get.snackbar` com mensagem e botão "Fazer upgrade" |

**Arquivos:**
- `lib/modules/home/home_module_controller.dart` – transações da home
- `lib/modules/insights/insights_module_controller.dart` – overview de insights

### 6.4 ResponseDto e warningMessage

`lib/models/dtos/response_dto.dart`:

```dart
late String? warningMessage;  // json['warningMessage']
```

Usado quando o backend retorna 200 com aviso de ajuste de intervalo de datas.

---

## 7. Endpoints utilizados

| Endpoint | Uso |
|----------|-----|
| `POST /api/subscriptions/validate-purchase` | Validar compra IAP (Apple receipt ou Google token); validação on-demand no app start (iOS) |
| `GET /api/subscriptions/me/plan` | Obter plano atual (fallback) |
| `POST /api/wallet` | Criar carteira (retorna 400 com `errorMsg` quando limite de carteiras atingido) |
| `POST /api/wallet/add-member` | Adicionar membro (retorna 403/409 com `errorMsg` quando limite de membros atingido) |
| `GET /api/transaction` | Transações (retorna 200 com `warningMessage` quando intervalo ajustado) |
| `GET /api/transaction/overview` | Overview (retorna 200 com `warningMessage` quando intervalo ajustado) |

---

## 8. Tela de planos (Paywall)

**Arquivos:** `lib/pages/plans/plans_page.dart`, `lib/pages/plans/plans_page_controller.dart`

- Layout focado em conversão: headline, subheadline, cards Plus e Pro
- Plus: "Mais popular", gradiente
- Pro: card secundário
- "Continuar no plano gratuito"
- "Restaurar compras" → `IapService.restorePurchases()`
- Texto legal Apple
- Navegação: banner na home → `/plans`

---

## 9. Restaurar compras

`IapService.restorePurchases()`:

1. Escuta `purchaseStream` para compras restauradas
2. Envia receipt/token ao backend via `validatePurchase`
3. Persiste receipt Apple (se aplicável)
4. Limpa cache de assinatura
5. Retorna sucesso ou erro; snackbar informa o resultado

---

## 10. Logout

- `PlanStateController.clearPlan()` → limpa `planCode`, `SubscriptionStateService.clearCache()`, `ReceiptStorageService.clearAppleReceipt()`

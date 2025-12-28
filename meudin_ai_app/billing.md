## 1. Visão geral da arquitetura (cobrança/planos/assinatura)

**Camadas:**

1. **Cliente**

   * App mobile (Flutter)
   * Web app (assinaturas / billing)

2. **Backend**

   * API própria em **Node.js (TypeScript)** no Render
   * Responsável por:

    * core da aplicação
    * checkout
    * webhooks
    * regras de assinatura
    * sincronização com Supabase

3. **Infra**

   * **Supabase**

    * Auth (fonte da verdade do usuário)
    * Banco de dados (subscriptions, plans, plan_limits, wallets…)
   * **Asaas**

    * cobrança
    * status de pagamento
    * recorrência

📌 **Supabase continua sendo a fonte de verdade de dados e permissões.
A API Node é a camada de orquestração.**

---

## 2. Modelo mental importante (regra-mãe)

* **Assinatura pertence ao usuário**
* **Limites pertencem ao plano**
* **Funcionalidades são habilitadas no contexto da carteira**
* **Carteira herda limites do plano do dono**

Isso já está perfeitamente refletido no seu schema.

---

## 3. Fluxo de autenticação (SSO real entre app e web)

### 3.1 App (Flutter)

* Usuário loga via **Supabase Auth**
* Você obtém:

  * `access_token`
  * `refresh_token`

### 3.2 Abrir Web App autenticado

Quando o usuário toca em **“Gerenciar assinatura”** no app:

1. App chama sua **API Node**

   ```
   POST /auth/sso
   Authorization: Bearer <supabase_access_token>
   ```

2. API:

   * valida token no Supabase
   * gera um **JWT curto (ex: 5 min)** específico para o web
   * retorna uma URL:

     ```
     https://billing.meudin.app/sso?token=xyz
     ```

O JWT web deve conter:
    sub (user_id Supabase)
    iat
    exp
    aud = billing_web

Não reutilizar access_token do Supabase no browser.

Evita:
    uso indevido do token do app
    vazamento de escopo

3. Web app:

   * valida o token na API
   * cria sessão web
   * usuário entra **sem login manual**

📌 Esse fluxo é o mesmo padrão usado por SaaS grandes.
Não parece gambiarra e passa tranquilamente em review.

---

## 4. Fluxo de assinatura (checkout Asaas)

### 4.1 Início do checkout (web)

1. Usuário escolhe plano (Plus / Pro)

2. Web chama API:

   ```
   POST /subscriptions/checkout
   body: { plan_code: 'plus' }
   ```

3. API:

   * busca plano em `plans`
   * cria cobrança no Asaas
   * salva **subscription PENDENTE** no Supabase:

     ```
     status = 'pending'
     provider = 'asaas'
     external_ref = id_asaas
     ```

1 usuário = no máximo 1 assinatura ativa
comportamento quando já existe assinatura
Sugestão de adição obrigatória:
Antes de criar nova cobrança:
verificar se existe assinatura ativa ou pendente
se existir, bloquear novo checkout ou substituir explicitamente

4. API retorna a **URL de pagamento do Asaas**

---

### 4.2 Confirmação via webhook (regra de ouro)

❌ Nunca confiar em redirect de sucesso
✅ Sempre usar **webhook**
Webhooks devem ser idempotentes:
usar external_ref como chave
ignorar eventos duplicados

1. Asaas chama:

   ```
   POST /webhooks/asaas
   ```

2. API valida assinatura do webhook

3. Atualiza `subscriptions`:

   * `status = 'active'`
   * `started_at`
   * `expires_at`

4. (Opcional) envia e-mail de confirmação

📌 A partir desse momento, o plano passa a valer **instantaneamente no app**.

Deixe o servico de notificacao no asaas 'false' para evitar cobrancas. Eles cobram 1 real adicional por email enviado na cobrança.

---

## 5. Como o app descobre o plano do usuário

### 5.1 Consulta padrão (login / refresh)

No login ou refresh de sessão:

```
GET /me/subscription
```

API retorna algo assim:

```json
{
  "plan": "pro",
  "limits": {
    "max_wallets": 20,
    "max_members_per_wallet": 20,
    "history_months": null,
    "can_export": true
  }
}
```

📌 Você pode cachear isso no app, mas **não confiar só nele**.

---

## 6. Fluxo de validação de limites (core do sistema)

### 6.1 Sempre baseado na carteira

Exemplo: usuário quer filtrar histórico.

1. App envia:

   ```
   GET /api/transaction?walletId=<uuid>&startDate=2024-01-01&endDate=2024-12-31
   ```

2. Backend:

   1. Busca `wallet.owner_id`
   2. Busca **assinatura ativa** do owner
   3. Busca `plan_limits`
   4. Calcula intervalo máximo permitido
   5. **Força o filtro no SQL**

Mesmo que o frontend tente burlar, o backend corta.

---

### 6.2 Exportação (pular a feature de exportaçao para esse momento. nao implementar export)

```
POST /wallets/{wallet_id}/export
```

Backend:

* identifica dono da carteira
* busca `can_export`
* se `false` → 403
* se `true` → gera export

---

## 7. Onde cada regra deve viver

### Frontend

✔️ UX
✔️ Mensagens claras
✔️ CTA de upgrade
❌ Nunca regra crítica

### Backend (Node API)

✔️ Checkout
✔️ Webhooks
✔️ Lógica de assinatura
✔️ Autorização entre serviços

### Supabase

✔️ Fonte de dados
✔️ Policies (RLS)
✔️ RPCs críticas (opcional)

📌 **RLS pode reforçar**, mas não substituir a API. Ou seja, RLS nunca deve conter lógica de plano, apenas controle de acesso (owner/member).

---

## 8. Fluxo de downgrade / expiração

Quando `expires_at < now()`:

1. API marca:

past_due → falha de pagamento temporária
canceled → cancelamento explícito
expired → término natural do período

2. Limites passam a ser:

   * plano free

3. Dados **não são apagados**

4. Funcionalidades ficam bloqueadas

5. CTA de reativação aparece

---

## 9. Resumo executivo

* ✅ Assinatura por usuário
* ✅ Limites aplicados por carteira
* ✅ Backend como fonte de verdade
* ✅ Web apenas para billing
* ✅ App simples, seguro e elegante
* ✅ Nada que gere rejeição em store

------------------------------------------------------------------------------------------------

## Cenarios / Casos de uso

Abaixo está um **conjunto de casos de uso estruturados como cenários de teste**. Eles cobrem **assinatura, herança de limites por carteira, downgrade, webhooks, e tentativas de bypass**.

Use isso literalmente como **documento de QA / critério de aceite**.

---

# Casos de Uso e Cenários de Teste — Monetização Meudin

## 1. Assinatura e plano do usuário

---

### UC-01 — Usuário sem assinatura (Plano Start)

**Pré-condições**

* Usuário criado
* Nenhuma assinatura ativa em `subscriptions`

**Ação**

* Usuário acessa o app

**Resultado esperado**

* Plano aplicado: `free`
* Limites:

  * até 2 carteiras
  * histórico limitado a 3 meses
  * até 1 membro adicional por carteira
* CTAs de upgrade visíveis

---

### UC-02 — Assinatura ativa via Asaas (Plano Plus)

**Pré-condições**

* Usuário possui assinatura `status = active`
* `plan_code = plus`

**Ação**

* Usuário acessa o app

**Resultado esperado**

* Plano Plus aplicado automaticamente
* Limites atualizados sem logout
* Acesso a:

  * filtros de até 1 ano
  * até 5 carteiras
  * até 5 membros por carteira
  * Benefícios extras ativos (relatório mensal / story elegível)

---

### UC-03 — Assinatura Pro ativa

**Pré-condições**

* Assinatura `status = active`
* `plan_code = pro`

**Ação**

* Usuário acessa qualquer carteira própria

**Resultado esperado**

* Filtros ilimitados
* Nenhuma restrição de histórico

---

## 2. Regra do dono da carteira (herança de limites)

---

### UC-04 — Usuário free convidado para carteira Pro

**Pré-condições**

* Usuário A: Plano Free
* Usuário B: Plano Pro
* Carteira X criada por B
* A adicionado como membro da Carteira X

**Ação**

* Usuário A acessa Carteira X

**Resultado esperado**

* Acesso a:

  * filtros ilimitados
  * exportação
  * múltiplos membros
* Limites baseados no plano do **dono (B)**

---

### UC-05 — Usuário free alterna entre carteiras

**Pré-condições**

* Usuário A:

  * dono da Carteira Y (Free)
  * membro da Carteira X (Pro)

**Ação**

* Usuário A alterna entre Carteira X e Y

**Resultado esperado**

* Carteira X → recursos Pro
* Carteira Y → restrições Free
* Mudança de comportamento imediata

---

### UC-06 — Usuário Plus convidado para carteira Free

**Pré-condições**

* Usuário A: Plano Plus
* Usuário B: Plano Free
* Carteira criada por B
* A adicionado como membro

**Ação**

* Usuário A acessa a carteira

**Resultado esperado**

* Limites seguem o plano **Free**
* Plano do membro **não eleva** a carteira

---

## 3. Limites técnicos e bloqueios

---

### UC-07 — Criação de carteira acima do limite

**Pré-condições**

* Usuário Free com 2 carteiras existentes

**Ação**

* Usuário tenta criar nova carteira

**Resultado esperado**

* Requisição negada pelo backend
* Erro 403 ou mensagem de limite atingido
* CTA de upgrade exibido

---

### UC-08 — Filtro de datas acima do permitido

**Pré-condições**

* Carteira cujo dono está no plano Free

**Ação**

* Usuário tenta filtrar transações com intervalo > 3 meses

**Resultado esperado**

* Backend limita o intervalo automaticamente (Backend força o intervalo máximo permitido e retorna os dados truncados)
* Frontend exibe aviso informativo ao usuário
* Nenhum dado fora do limite é retornado

---

### UC-09 — Tentativa de exportação sem permissão

**Pré-condições**

* Carteira com `can_export = false`

**Ação**

* Usuário chama endpoint de exportação

**Resultado esperado**

* Resposta 403
* Nenhum arquivo gerado

---

## 4. Checkout e webhooks

---

### UC-10 — Checkout iniciado, pagamento pendente

**Pré-condições**

* Usuário sem assinatura

**Ação**

* Usuário inicia checkout
* Não conclui pagamento

**Resultado esperado**

* `subscription.status = pending`
* Nenhuma funcionalidade premium liberada
* Mensagem de feedback em portugues pro usuario

---

### UC-11 — Webhook de pagamento confirmado

**Pré-condições**

* Assinatura pendente criada
* Webhook Asaas válido recebido

**Ação**

* API processa webhook

**Resultado esperado**

* `status = active`
* `started_at` e `expires_at` preenchidos
* App reflete plano ativo imediatamente

---

### UC-12 — Webhook inválido ou repetido

**Pré-condições**

* Webhook duplicado ou com assinatura inválida

**Ação**

* API recebe webhook

**Resultado esperado**

* Rejeição silenciosa ou logada
* Nenhuma alteração indevida na assinatura

---

## 5. Downgrade, expiração e cancelamento

---

### UC-13 — Assinatura expirada

**Pré-condições**

* `expires_at < now()`

**Ação**

* Usuário acessa app

**Resultado esperado**

* Plano aplicado volta para Free
* Dados preservados
* Funcionalidades premium bloqueadas

---

### UC-14 — Cancelamento manual

**Pré-condições**

* Assinatura ativa

**Ação**

* Usuário cancela assinatura

**Resultado esperado**

* Benefícios válidos até `expires_at`
* Após a data, downgrade automático

---

## 6. Benefícios extras (relatórios e stories)

---

### UC-15 — Envio de relatório mensal (deixar estrutura generia para o envio, ainda nao decidi o conteudo do relatorio)

**Pré-condições**

* Usuário Plus ou Pro ativo

**Ação**

* Job mensal executado

**Resultado esperado**

* Relatório enviado por e-mail do usuario assinante
* Nenhum envio para usuários Free

---

### UC-16 — Solicitação de story

**Pré-condições**

* Usuário Plus ou Pro
* Não utilizou benefício no mês

**Ação**

* Usuário solicita divulgação (via plataforma web)

**Resultado esperado**

* Solicitação registrada (com campo de texto digitado pelo usuario)
* Status inicial: “em análise”
* Nenhuma garantia de aprovação

---

### UC-17 — Nova solicitação após recusa

**Pré-condições**

* Solicitação recusada

**Ação**

* Usuário envia nova solicitação

**Resultado esperado**

* Nova entrada criada
* Sem bloqueio por tentativa anterior

---

## 7. Segurança e bypass

---

### UC-18 — Bypass via frontend

**Pré-condições**

* Usuário Free altera parâmetros no app

**Ação**

* Chamada direta à API com payload adulterado

**Resultado esperado**

* Backend aplica limites corretos
* Nenhum dado indevido retornado

---

### UC-19 — Usuário tenta acessar carteira sem permissão

**Pré-condições**

* Usuário não é membro da carteira

**Ação**

* Chamada direta para endpoints da carteira

**Resultado esperado**

* 403 ou 404
* Nenhuma informação vazada

---

## 8. Casos extremos (edge cases)

---

### UC-20 — Dono da carteira perde assinatura

**Pré-condições**

* Carteira criada por usuário Pro
* Membros ativos

**Ação**

* Assinatura do dono expira

**Resultado esperado**

* Carteira inteira sofre downgrade
* Membros perdem acesso às funcionalidades premium

---

### UC-21 — Dono troca de plano (Plus → Pro)

**Pré-condições**

* Carteira ativa
* Assinatura alterada

**Ação**

* Webhook de upgrade recebido

**Resultado esperado**

* Limites atualizados imediatamente
* Nenhuma inconsistência de dados

---

## 9. Entregável para o time

Você pode passar isso como:

* **Documento de QA**
* **Critérios de aceite**
* **Checklist de validação de release**

Este documento define o comportamento esperado do sistema.
Decisões não descritas aqui devem seguir o modelo mental da Seção 2.
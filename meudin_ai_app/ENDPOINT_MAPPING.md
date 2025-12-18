# 🗺️ Mapeamento de Endpoints - Antes vs Depois

## 📊 Tabela de Comparação Completa

| Serviço | Método Antigo | Endpoint Antigo | Endpoint Novo | Mudanças Principais |
|---------|---------------|-----------------|---------------|---------------------|
| **AUTENTICAÇÃO** |
| Login | `POST` | `/logIn` | `/api/auth/login` | ✅ Estrutura simplificada |
| Registro | `POST` | `/createNewUser` | `/api/auth/register` | ✅ Removido wrapper `newUserDto` |
| Enviar Código | `POST` | `/sendVerificationCode` | `/api/auth/send-verification-code` | ✅ Público (sem token) |
| Validar Código | `POST` | `/validateVerificationCode` | `/api/auth/validate-verification-code` | ✅ `verificationCode` → `code` |
| Atualizar Senha | `POST` | `/updatePassword` | `/api/auth/update-password` | ✅ `userMail` → `email` |
| **TRANSAÇÕES** |
| Criar Despesa | `POST` | `/saveTransaction` | `/api/transaction/waste` | ✅ Endpoint dedicado |
| Criar Receita | `POST` | `/saveTransaction` | `/api/transaction/revenue` | ✅ Endpoint dedicado |
| Listar | `POST` | `/getTransactionsByWalletIdAndDateInterval` | `GET /api/transaction` | ⚡ POST → GET + query params |
| Overview | ❌ | N/A | `GET /api/transaction/overview` | ✨ Novo endpoint |
| **CARTEIRAS** |
| Listar | `POST` | `/getUserWallets` | `GET /api/wallet` | ⚡ POST → GET + query params |
| Criar | ❌ | N/A | `POST /api/wallet` | ✨ Novo endpoint |
| Adicionar Membro | ❌ | N/A | `POST /api/wallet/add-member` | ✨ Novo endpoint |
| Remover Membro | ❌ | N/A | `POST /api/wallet/remove-member` | ✨ Novo endpoint |
| Listar Membros | ❌ | N/A | `GET /api/wallet/members` | ✨ Novo endpoint |
| **CATEGORIAS** |
| Listar | `GET` | `/getSpendingCategories` | `/api/spending-categories` | ✅ Agora é público |

---

## 🎯 Legenda

- ✅ Endpoint atualizado
- ✨ Novo endpoint adicionado
- ⚡ Mudança de método HTTP
- ❌ Não existia antes

---

## 📋 Estrutura de Bodies - Antes vs Depois

### Registro de Usuário

**Antes:**
```json
{
  "newUserDto": {
    "name": "João",
    "email": "joao@email.com",
    "password": "senha123"
  }
}
```

**Depois:**
```json
{
  "name": "João",
  "email": "joao@email.com",
  "password": "senha123"
}
```

---

### Criar Despesa

**Antes:**
```json
{
  "newTransactionDto": {
    "userId": "uuid",
    "walletId": "uuid",
    "amount": 100.50,
    "type": "waste",
    "reason": "Almoço",
    "categoryId": "food",
    "transactionDate": "2025-01-15T10:30:00.000Z"
  }
}
```

**Depois:**
```json
{
  "waste": 100.50,
  "walletId": "uuid",
  "reason": "Almoço",
  "categoryId": "food",
  "uid": "uuid",
  "spendDate": "2025-01-15T10:30:00.000Z"
}
```

---

### Criar Receita

**Antes:**
```json
{
  "newTransactionDto": {
    "userId": "uuid",
    "walletId": "uuid",
    "amount": 5000.00,
    "type": "revenue",
    "reason": "Salário",
    "transactionDate": "2025-01-15T10:30:00.000Z"
  }
}
```

**Depois:**
```json
{
  "amount": 5000.00,
  "walletId": "uuid",
  "reason": "Salário",
  "uid": "uuid",
  "payDay": "2025-01-15T10:30:00.000Z"
}
```

---

### Listar Transações

**Antes:**
```json
POST /getTransactionsByWalletIdAndDateInterval
{
  "walletId": "uuid",
  "userId": "uuid",
  "startDate": "2025-01-01T00:00:00.000Z",
  "endDate": "2025-01-31T23:59:59.999Z"
}
```

**Depois:**
```
GET /api/transaction?walletId=uuid&startDate=2025-01-01&endDate=2025-01-31
```

---

### Listar Carteiras

**Antes:**
```json
POST /getUserWallets
{
  "uid": "uuid"
}
```

**Depois:**
```
GET /api/wallet?userId=uuid
```

---

## 🔑 Headers de Autenticação

### Endpoints Públicos (sem token)
```
Content-Type: application/json
```

**Endpoints:**
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/send-verification-code`
- `POST /api/auth/validate-verification-code`
- `POST /api/auth/update-password`
- `GET /api/spending-categories`

---

### Endpoints Protegidos (com token)
```
Content-Type: application/json
Authorization: Bearer <JWT_TOKEN>
```

**Endpoints:**
- `GET /api/auth/me`
- `GET /api/wallet`
- `POST /api/wallet`
- `POST /api/wallet/add-member`
- `POST /api/wallet/remove-member`
- `GET /api/wallet/members`
- `GET /api/transaction`
- `POST /api/transaction`
- `POST /api/transaction/waste`
- `POST /api/transaction/revenue`
- `GET /api/transaction/overview`

---

## 📅 Formato de Datas

### Para Query Params (GET)
```
YYYY-MM-DD
Exemplo: 2025-01-15
```

### Para Request Body (POST)
```
ISO 8601 completo (com hora)
Exemplo: 2025-01-15T10:30:00.000Z
```

---

## 🔄 Estrutura de Response Padrão

Todos os endpoints agora retornam:

```json
{
  "success": true,
  "data": { ... }
}
```

Ou em caso de erro:

```json
{
  "success": false,
  "errorMsg": "Mensagem de erro"
}
```

---

## 🚀 Novos Recursos Disponíveis

### 1. Overview Endpoint
Retorna dados agregados para a tela principal:
```
GET /api/transaction/overview?walletId=xxx&startDate=2025-01-01&endDate=2025-01-31
```

**Response:**
```json
{
  "success": true,
  "data": {
    "balance": 1500.50,
    "income": 5000.00,
    "spends": -3499.50,
    "spendsByCategory": [
      { "a": "Alimentação", "b": 800.00 },
      { "a": "Transporte", "b": 500.00 }
    ],
    "pieChartData": [...]
  }
}
```

### 2. Gestão de Membros
Agora é possível:
- Adicionar membros por email
- Remover membros
- Listar membros de uma carteira

### 3. Criação de Carteiras
Endpoint dedicado para criar novas carteiras.

---

## ⚠️ Breaking Changes

1. **Métodos HTTP:** Vários endpoints mudaram de `POST` para `GET`
2. **Estrutura de Body:** Removidos wrappers como `newUserDto`, `newTransactionDto`
3. **Nomes de Campos:**
   - `userMail` → `email`
   - `verificationCode` → `code`
   - `amount` → `waste` (para despesas)
   - `transactionDate` → `spendDate` (despesas) ou `payDay` (receitas)
4. **Query Params:** Datas agora são `YYYY-MM-DD` nos GET requests
5. **Autenticação:** Alguns endpoints que antes requeriam token agora são públicos

---

## ✅ Validação Rápida

Use este checklist para validar a integração:

- [ ] Login funciona e retorna token
- [ ] Registro funciona e cria carteira padrão
- [ ] Listagem de carteiras traz dados corretos
- [ ] Criação de despesa salva no banco
- [ ] Criação de receita salva no banco
- [ ] Listagem de transações retorna período correto
- [ ] Overview retorna dados agregados
- [ ] Categorias carregam sem autenticação
- [ ] Adicionar membro à carteira funciona
- [ ] Remover membro funciona
- [ ] Recuperação de senha funciona


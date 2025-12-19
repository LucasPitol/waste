# Gerenciamento de Sessão - Implementação

## 📋 Resumo

Implementamos um sistema robusto de gerenciamento de sessão usando `flutter_secure_storage` para armazenar dados sensíveis (tokens) de forma segura e `shared_preferences` para dados não sensíveis.

## 🔐 Segurança

### Armazenamento 100% Seguro
- **TODOS os dados**: Armazenados usando `flutter_secure_storage`
- **iOS**: Keychain com `KeychainAccessibility.first_unlock`
- **Android**: Encrypted Shared Preferences
- **Dados incluídos**: Token JWT, informações do usuário, carteiras, saldo
- **Vantagem**: Máxima segurança para dados financeiros sensíveis
- **Nota**: Ligeiramente mais lento que `shared_preferences`, mas muito mais seguro

### Fluxo de Autenticação

1. **Login**:
   - Usuário faz login → API retorna token JWT
   - Token é armazenado no secure storage
   - Dados do usuário são armazenados localmente
   - `UserService.currentUser` é atualizado

2. **Auto-login** (Splash Screen):
   - App verifica se existe token válido
   - Se sim, restaura sessão do usuário
   - Se não, redireciona para login

3. **Logout**:
   - Limpa todos os dados locais (secure storage + shared preferences)
   - Limpa `UserService.currentUser`
   - Redireciona para tela de login

## 🏗️ Arquitetura

### Serviços Implementados

#### 1. `LocalStorageService`
Gerencia o armazenamento local de dados do usuário usando **exclusivamente** `flutter_secure_storage`.

**Métodos principais:**
- `storeUserData(User user)`: Salva todos os dados do usuário criptografados
- `getUserData()`: Recupera e descriptografa dados do usuário
- `deleteUserData()`: Remove todos os dados seguros
- `hasValidSession()`: Verifica se há sessão válida
- `getToken()`: Retorna o token armazenado
- `updateCurrentWalletId(String walletId)`: Atualiza carteira atual
- `updateWalletList(List<Wallet> wallets)`: Atualiza lista de carteiras

**Dados armazenados:**
- **Secure Storage**: `secure_user_data` (JSON completo criptografado)
  - Token JWT
  - ID do usuário
  - Nome e email
  - Carteira atual
  - Lista completa de carteiras
  - Datas de criação

**Por que 100% secure storage?**
- Dados financeiros são sensíveis e devem ser protegidos
- Informações de carteiras podem revelar padrões de gastos
- Keychain (iOS) e Encrypted SharedPreferences (Android) são muito mais seguros
- Pequena perda de performance é aceitável para segurança máxima

#### 2. `SessionService`
Camada de abstração para gerenciar sessões.

**Métodos principais:**
- `tryAutoLogin()`: Tenta restaurar sessão automaticamente
- `saveSession()`: Salva sessão atual
- `logout()`: Encerra sessão
- `getToken()`: Obtém token atual
- `updateCurrentWalletId(String walletId)`: Atualiza carteira

#### 3. `UserService`
Gerencia autenticação e dados do usuário.

**Novo método:**
- `getAuthHeaders()`: Retorna headers HTTP com token de autenticação

### Modelos Atualizados

#### `User`
- Adicionado método `toJson()` completo incluindo `walletList`

#### `Wallet`
- Adicionado método `toJson()`
- Melhorado `fromJson()` para lidar com campos alternativos da API

## 🎨 UI Implementada

### Página de Perfil
- Exibe informações do usuário
- Botão de logout
- Design moderno e limpo
- Rota: `/profile`

### Navegação
- Botão de perfil no `HomeAppBar` agora navega para a página de perfil
- Logout redireciona para tela de login

## 🔄 Fluxo Completo

```
App Start
    ↓
Splash Screen
    ↓
SessionService.tryAutoLogin()
    ↓
    ├─ Token válido? → Home
    └─ Não → Login
         ↓
    UserService.signInByEmailAndPassword()
         ↓
    LocalStorageService.storeUserData()
         ↓
    Home
         ↓
    [Usuário usa o app]
         ↓
    Profile → Logout
         ↓
    SessionService.logout()
         ↓
    Login
```

## 📡 Requisições HTTP

Todos os serviços agora incluem o token JWT nos headers:

```dart
final headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',
};
```

**Serviços atualizados:**
- ✅ `UserService`
- ✅ `WalletService`
- ✅ `TransactionService`

## 🔧 Recomendações para a API

### 1. Token JWT
Certifique-se de que o token JWT retornado no login:
- ✅ Seja incluído na resposta de login em `data.token`
- ✅ Tenha tempo de expiração adequado (recomendado: 7-30 dias)
- ✅ Seja validado em todos os endpoints protegidos

### 2. Refresh Token (Recomendado)
Para melhor segurança, considere implementar:

```typescript
// Resposta de login
{
  "success": true,
  "data": {
    "id": "user-id",
    "displayName": "Nome",
    "email": "email@example.com",
    "token": "access-token-jwt",  // Expira em 1h
    "refreshToken": "refresh-token-jwt",  // Expira em 30 dias
    "currentWalletId": "wallet-id",
    "walletList": [...]
  }
}

// Novo endpoint: POST /api/auth/refresh
{
  "refreshToken": "refresh-token-jwt"
}

// Resposta
{
  "success": true,
  "data": {
    "token": "new-access-token-jwt",
    "refreshToken": "new-refresh-token-jwt"
  }
}
```

### 3. Validação de Token
Todos os endpoints protegidos devem:
- Verificar presença do header `Authorization: Bearer <token>`
- Validar o token JWT
- Retornar `401 Unauthorized` se inválido
- Retornar `403 Forbidden` se expirado

### 4. Resposta de Erro Padronizada
```json
{
  "success": false,
  "errorMessage": "Token expirado",
  "errorCode": "TOKEN_EXPIRED"
}
```

### 5. Logout (Opcional)
Considere implementar um endpoint de logout para invalidar tokens:

```
POST /api/auth/logout
Authorization: Bearer <token>
```

Isso permite invalidar tokens no servidor (útil se implementar blacklist).

## 🧪 Testando

### Teste de Login
1. Faça login com credenciais válidas
2. Feche o app completamente
3. Reabra o app
4. ✅ Deve ir direto para Home (auto-login)

### Teste de Logout
1. Faça login
2. Navegue para Perfil
3. Clique em "Sair"
4. ✅ Deve voltar para tela de Login
5. ✅ Não deve fazer auto-login na próxima abertura

### Teste de Token Inválido
1. Faça login
2. Invalide o token no servidor (ou espere expirar)
3. Tente fazer uma ação que requer autenticação
4. ✅ Deve receber erro 401
5. ✅ App deve redirecionar para login

## 📦 Dependências

```yaml
dependencies:
  flutter_secure_storage: ^9.2.2  # Única dependência de storage necessária
  # shared_preferences: REMOVIDO - não é seguro o suficiente para dados financeiros
```

**Migração de `shared_preferences` para `flutter_secure_storage`:**
- ✅ Todos os dados agora criptografados
- ✅ Proteção contra acesso não autorizado
- ✅ Conformidade com melhores práticas de segurança
- ✅ Ideal para aplicativos financeiros

## 🔒 Considerações de Segurança

1. ✅ **Todos os dados criptografados**: Usando `flutter_secure_storage`
2. ✅ **Nunca** armazene senhas localmente
3. ✅ **Sempre** use HTTPS para comunicação com a API
4. ✅ **Keychain/Encrypted Storage**: Proteção nativa do sistema operacional
5. **Implemente** refresh tokens para melhor segurança (recomendado)
6. **Considere** adicionar biometria para re-autenticação (próximo passo)
7. **Monitore** tentativas de login suspeitas

### Por que 100% Secure Storage?

**Dados sensíveis em apps financeiros:**
- 💰 Saldos e transações
- 🏦 Informações de carteiras
- 👥 Membros e permissões
- 📊 Padrões de gastos

**Ameaças mitigadas:**
- ❌ Acesso físico ao dispositivo
- ❌ Malware com acesso ao sistema de arquivos
- ❌ Backup não criptografado
- ❌ Engenharia reversa do app

**Proteções ativas:**
- ✅ Criptografia AES-256
- ✅ Keychain (iOS) com proteção de hardware
- ✅ EncryptedSharedPreferences (Android)
- ✅ Dados apagados no logout
- ✅ Validação de integridade ao ler

## 🚀 Próximos Passos (Opcional)

1. **Refresh Token**: Implementar renovação automática de tokens
2. **Biometria**: Adicionar autenticação biométrica (Face ID/Touch ID)
3. **Timeout de Sessão**: Logout automático após inatividade
4. **Multi-dispositivo**: Gerenciar sessões em múltiplos dispositivos
5. **Notificações**: Alertar sobre novos logins

## 📝 Notas

- O sistema é retrocompatível com a API atual
- Todos os logs de debug foram removidos para produção
- A sessão persiste entre reinicializações do app
- Os dados são limpos completamente no logout


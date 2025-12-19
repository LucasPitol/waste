# 📘 Guia de Migração para HttpClient

## 🎯 Objetivo

Migrar os serviços existentes para usar o novo `HttpClient` que possui:
- ✅ Tratamento automático de erros 401
- ✅ Refresh token automático
- ✅ Retry automático após renovação
- ✅ Código mais limpo e conciso

## 🔄 Padrão de Migração

### Antes (usando http diretamente)

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<ResponseDto> getTransactionDtoList(
  String walletId,
  DateTime startDate,
  DateTime endDate,
) async {
  final user = _userService.getCurrentUser();
  final authToken = user?.token;

  final url = Uri.parse('${apiUrl}transaction?walletId=$walletId&startDate=$startDateStr&endDate=$endDateStr');

  final headers = {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  final response = await http.get(url, headers: headers);

  ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

  return responseDto;
}
```

### Depois (usando HttpClient)

```dart
import 'package:meudin_ai_app/services/http_client.dart';
import 'package:meudin_ai_app/services/user_service.dart';

Future<ResponseDto> getTransactionDtoList(
  String walletId,
  DateTime startDate,
  DateTime endDate,
) async {
  final url = Uri.parse('${apiUrl}transaction?walletId=$walletId&startDate=$startDateStr&endDate=$endDateStr');

  return await HttpClient.get(
    url,
    headers: UserService.getAuthHeaders(),
  );
}
```

## 📊 Comparação

| Aspecto | Antes | Depois | Benefício |
|---------|-------|--------|-----------|
| **Linhas de código** | ~15 | ~8 | -47% |
| **Imports** | 2 | 2 | = |
| **Tratamento de 401** | ❌ Manual | ✅ Automático | ✓ |
| **Refresh token** | ❌ Não | ✅ Sim | ✓ |
| **Retry** | ❌ Não | ✅ Sim | ✓ |
| **Headers auth** | ❌ Manual | ✅ Automático | ✓ |
| **Parse JSON** | ❌ Manual | ✅ Automático | ✓ |

## 🔧 Passo a Passo

### 1. Atualizar Imports

**Remover:**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
```

**Adicionar:**
```dart
import 'package:meudin_ai_app/services/http_client.dart';
import 'package:meudin_ai_app/services/user_service.dart';
```

### 2. Simplificar Headers

**Antes:**
```dart
final user = _userService.getCurrentUser();
final authToken = user?.token;

final headers = {
  'Content-Type': 'application/json',
  if (authToken != null) 'Authorization': 'Bearer $authToken',
};
```

**Depois:**
```dart
final headers = UserService.getAuthHeaders();
```

### 3. Substituir Chamadas HTTP

#### GET Request

**Antes:**
```dart
final response = await http.get(url, headers: headers);
ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));
return responseDto;
```

**Depois:**
```dart
return await HttpClient.get(url, headers: headers);
```

#### POST Request

**Antes:**
```dart
final response = await http.post(url, body: jsonEncode(body), headers: headers);
ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));
return responseDto;
```

**Depois:**
```dart
return await HttpClient.post(
  url,
  headers: headers,
  body: jsonEncode(body),
);
```

#### PUT Request

**Antes:**
```dart
final response = await http.put(url, body: jsonEncode(body), headers: headers);
ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));
return responseDto;
```

**Depois:**
```dart
return await HttpClient.put(
  url,
  headers: headers,
  body: jsonEncode(body),
);
```

#### DELETE Request

**Antes:**
```dart
final response = await http.delete(url, headers: headers);
ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));
return responseDto;
```

**Depois:**
```dart
return await HttpClient.delete(url, headers: headers);
```

## 📝 Exemplo Completo: TransactionService

### Antes

```dart
import 'dart:convert';
import 'package:meudin_ai_app/environment/environment.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:http/http.dart' as http;
import 'package:meudin_ai_app/services/user_service.dart';

class TransactionService {
  String apiUrl = Environment.apiUrl;
  late UserService _userService;

  TransactionService() {
    _userService = UserService();
  }
  
  Future<ResponseDto> getTransactionDtoList(
    String walletId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final user = _userService.getCurrentUser();
    final authToken = user?.token;

    final startDateStr = '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endDateStr = '${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    final url = Uri.parse('${apiUrl}transaction?walletId=$walletId&startDate=$startDateStr&endDate=$endDateStr');

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final response = await http.get(url, headers: headers);

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }
}
```

### Depois

```dart
import 'package:meudin_ai_app/environment/environment.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/services/http_client.dart';
import 'package:meudin_ai_app/services/user_service.dart';

class TransactionService {
  String apiUrl = Environment.apiUrl;

  Future<ResponseDto> getTransactionDtoList(
    String walletId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startDateStr = '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endDateStr = '${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    final url = Uri.parse('${apiUrl}transaction?walletId=$walletId&startDate=$startDateStr&endDate=$endDateStr');

    return await HttpClient.get(
      url,
      headers: UserService.getAuthHeaders(),
    );
  }
}
```

## 🎯 Serviços a Migrar

### Alta Prioridade (endpoints protegidos)
- [ ] `TransactionService.getTransactionDtoList()`
- [ ] `TransactionService.saveNewSpend()`
- [ ] `TransactionService.saveNewRevenue()`
- [ ] `TransactionService.getOverview()`
- [ ] `WalletService.getUserWallets()`
- [ ] `WalletService.createWallet()`
- [ ] `WalletService.addMemberToWallet()`
- [ ] `WalletService.removeMemberFromWallet()`
- [ ] `WalletService.getWalletMembers()`

### Baixa Prioridade (endpoints públicos)
- [ ] `SpendingCategoryService.getSpendingCategories()` (público, mas pode migrar para consistência)
- [ ] `UserService.signInByEmailAndPassword()` (já implementado, não precisa migrar)
- [ ] `UserService.createNewUser()` (já implementado, não precisa migrar)

## ⚠️ Casos Especiais

### 1. Endpoints Públicos (sem autenticação)

Para endpoints que não precisam de autenticação, você pode omitir os headers ou passar headers vazios:

```dart
return await HttpClient.get(
  url,
  headers: {
    'Content-Type': 'application/json',
  },
);
```

### 2. Upload de Arquivos

Se você precisar fazer upload de arquivos no futuro, use `HttpInterceptor.postRaw()`:

```dart
final response = await HttpInterceptor.postRaw(
  url,
  headers: headers,
  body: multipartRequest,
);
```

### 3. Tratamento de Erros Específicos

Se você precisar tratar erros específicos além de 401:

```dart
final responseDto = await HttpClient.get(url, headers: headers);

if (!responseDto.success) {
  // Tratar erro específico
  if (responseDto.errorMessage?.contains('not found') ?? false) {
    // Tratar 404
  }
}
```

## 🧪 Testes Após Migração

Para cada serviço migrado, teste:

1. **Requisição Normal**
   - ✅ Deve funcionar normalmente
   - ✅ Deve retornar dados corretos

2. **Token Expirado**
   - ✅ Deve renovar token automaticamente
   - ✅ Deve repetir requisição
   - ✅ Deve retornar dados corretos

3. **Token Inválido**
   - ✅ Deve redirecionar para login
   - ✅ Deve limpar dados locais

4. **Erro de Rede**
   - ✅ Deve retornar erro apropriado
   - ✅ Não deve causar crash

## 📊 Progresso da Migração

```
Total: 9 métodos
Migrados: 0
Pendentes: 9
Progresso: [░░░░░░░░░░] 0%
```

## 🎉 Benefícios Após Migração Completa

- ✅ Código 47% mais conciso
- ✅ Tratamento consistente de erros
- ✅ Renovação automática de tokens
- ✅ Melhor experiência do usuário
- ✅ Menos bugs relacionados a autenticação
- ✅ Código mais fácil de manter
- ✅ Testes mais simples

## 🚀 Próximos Passos

1. Migrar `TransactionService` (exemplo acima)
2. Migrar `WalletService`
3. Testar cada migração
4. Atualizar progresso neste documento
5. Remover imports não utilizados
6. Celebrar! 🎉


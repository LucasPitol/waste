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
  
  Future<ResponseDto> saveNewSpend(
    String amount,
    String reason,
    String? categoryId,
    DateTime selectedDate,
  ) async {
    final user = _userService.getCurrentUser();
    final walletId = user?.currentWalletId;
    final authToken = user?.token;

    if (walletId == null || walletId.isEmpty) {
      return ResponseDto(
        success: false,
        errorMessage: 'Carteira não encontrada',
      );
    }

    if (authToken == null || authToken.isEmpty) {
      return ResponseDto(
        success: false,
        errorMessage: 'Token de autenticação não encontrado',
      );
    }

    final url = Uri.parse('${apiUrl}transaction');

    // Converter valor
    String cleanAmount = amount.trim();
    cleanAmount = cleanAmount.replaceAll(RegExp(r'[^0-9.,]'), '');
    if (cleanAmount.contains(',') &&
        cleanAmount.lastIndexOf(',') > cleanAmount.lastIndexOf('.')) {
      cleanAmount = cleanAmount.replaceAll('.', '');
      cleanAmount = cleanAmount.replaceAll(',', '.');
    } else {
      cleanAmount = cleanAmount.replaceAll(',', '');
    }
    final parsedAmount = -(double.tryParse(cleanAmount) ?? 0.0);

    if (parsedAmount == 0.0) {
      return ResponseDto(
        success: false,
        errorMessage: 'Valor inválido',
      );
    }

    final Map<String, dynamic> body = {
      'type': 'waste',
      'amount': parsedAmount,
      'walletId': walletId,
      'transactionDate': selectedDate.toIso8601String(),
    };
    
    if (reason.isNotEmpty) {
      body['reason'] = reason;
    }
    
    if (categoryId != null && categoryId.isNotEmpty) {
      body['categoryId'] = categoryId;
    }

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null && authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };

    final response = await http.post(url, body: jsonEncode(body), headers: headers);
    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }

  Future<ResponseDto> saveNewRevenue(
    String amount,
    String reason,
    DateTime selectedDate,
  ) async {
    final user = _userService.getCurrentUser();
    final walletId = user?.currentWalletId;
    final authToken = user?.token;

    if (walletId == null || walletId.isEmpty) {
      return ResponseDto(
        success: false,
        errorMessage: 'Carteira não encontrada',
      );
    }

    if (authToken == null || authToken.isEmpty) {
      return ResponseDto(
        success: false,
        errorMessage: 'Token de autenticação não encontrado',
      );
    }

    final url = Uri.parse('${apiUrl}transaction');

    // Robust currency string to double conversion
    String cleanAmount = amount.trim();
    // Remove currency symbol and spaces
    cleanAmount = cleanAmount.replaceAll(RegExp(r'[^0-9.,]'), '');
    // If comma is the decimal separator (e.g., 3.000,50)
    if (cleanAmount.contains(',') &&
        cleanAmount.lastIndexOf(',') > cleanAmount.lastIndexOf('.')) {
      cleanAmount = cleanAmount.replaceAll('.', ''); // remove thousand sep
      cleanAmount = cleanAmount.replaceAll(',', '.'); // convert decimal sep
    } else {
      cleanAmount = cleanAmount.replaceAll(',', ''); // remove thousand sep
    }
    // Para receitas, o valor deve ser positivo
    final parsedAmount = double.tryParse(cleanAmount) ?? 0.0;

    if (parsedAmount == 0.0) {
      return ResponseDto(
        success: false,
        errorMessage: 'Valor inválido',
      );
    }

    // Montar body conforme especificação da API
    // Campos obrigatórios: type, amount, transactionDate, walletId
    // Campos opcionais: reason
    // categoryId NÃO é enviado para receitas (apenas para despesas)
    final Map<String, dynamic> body = {
      'type': 'revenue', // OBRIGATÓRIO
      'amount': parsedAmount, // OBRIGATÓRIO (positivo para receitas)
      'walletId': walletId, // OBRIGATÓRIO (validado antes)
      'transactionDate': selectedDate.toIso8601String(), // OBRIGATÓRIO
    };
    
    // Campos opcionais - só adiciona se tiver valor
    if (reason.isNotEmpty) {
      body['reason'] = reason;
    }
    
    // categoryId NÃO é enviado para receitas (apenas para despesas)

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final response = await http.post(url, body: jsonEncode(body), headers: headers);

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }

  Future<ResponseDto> getTransactionDtoList(
    String walletId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final user = _userService.getCurrentUser();
    final authToken = user?.token;

    // Format dates to YYYY-MM-DD
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

  Future<ResponseDto> getOverview(
    String walletId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final user = _userService.getCurrentUser();
    final authToken = user?.token;

    // Format dates to YYYY-MM-DD
    final startDateStr = '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endDateStr = '${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    final url = Uri.parse('${apiUrl}transaction/overview?walletId=$walletId&startDate=$startDateStr&endDate=$endDateStr');

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final response = await http.get(url, headers: headers);

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }
}

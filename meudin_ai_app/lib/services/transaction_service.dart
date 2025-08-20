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
    final userId = user?.id;
    final walletId = user?.currentWalletId;
    final authToken = user?.token;

    final url = Uri.parse('${apiUrl}saveTransaction');

    // Robust currency string to double conversion
    String cleanAmount = amount.trim();
    cleanAmount = cleanAmount.replaceAll(RegExp(r'[^0-9.,]'), '');
    if (cleanAmount.contains(',') &&
        cleanAmount.lastIndexOf(',') > cleanAmount.lastIndexOf('.')) {
      cleanAmount = cleanAmount.replaceAll('.', '');
      cleanAmount = cleanAmount.replaceAll(',', '.');
    } else {
      cleanAmount = cleanAmount.replaceAll(',', '');
    }
    final parsedAmount = double.tryParse(cleanAmount) ?? 0.0;

    final Map<String, dynamic> newTransactionDto = {
      'reason': reason,
      'amount': parsedAmount,
      'transactionDate': selectedDate.toIso8601String(),
      'userId': userId,
      'walletId': walletId,
      'type': "waste",
    };
    if (categoryId != null && categoryId.isNotEmpty) {
      newTransactionDto['categoryId'] = categoryId;
    }

    final body = jsonEncode({
      'newTransactionDto': newTransactionDto,
    });

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final response = await http.post(url, body: body, headers: headers);

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }

  Future<ResponseDto> saveNewRevenue(
    String amount,
    String reason,
    DateTime selectedDate,
  ) async {
    final user = _userService.getCurrentUser();
    final userId = user?.id;
    final walletId = user?.currentWalletId;
    final authToken = user?.token;

    final url = Uri.parse('${apiUrl}saveTransaction');

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
    final parsedAmount = double.tryParse(cleanAmount) ?? 0.0;

    final body = jsonEncode({
      'newTransactionDto': {
        'reason': reason,
        'amount': parsedAmount,
        'transactionDate': selectedDate.toIso8601String(),
        'userId': userId,
        'walletId': walletId,
        'type': "revenue",
      }
    });

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final response = await http.post(url, body: body, headers: headers);

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }

  Future<ResponseDto> getTransactionDtoList(
    String walletId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final user = _userService.getCurrentUser();
    final userId = user?.id;
    final authToken = user?.token;

    final url = Uri.parse('${apiUrl}getTransactionsByWalletIdAndDateInterval');
    final body = jsonEncode({
      'walletId': walletId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'userId': userId,
    });

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

    final response = await http.post(url, body: body, headers: headers);

    ResponseDto responseDto = ResponseDto.fromJson(jsonDecode(response.body));

    return responseDto;
  }
}

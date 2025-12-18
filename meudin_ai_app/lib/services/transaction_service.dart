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

    final url = Uri.parse('${apiUrl}transaction/waste');

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

    final Map<String, dynamic> body = {
      'waste': parsedAmount,
      'walletId': walletId,
    };
    
    if (reason.isNotEmpty) {
      body['reason'] = reason;
    }
    
    if (categoryId != null && categoryId.isNotEmpty) {
      body['categoryId'] = categoryId;
    }
    
    if (userId != null) {
      body['uid'] = userId;
    }
    
    body['spendDate'] = selectedDate.toIso8601String();

    final headers = {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
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
    final userId = user?.id;
    final walletId = user?.currentWalletId;
    final authToken = user?.token;

    final url = Uri.parse('${apiUrl}transaction/revenue');

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

    final Map<String, dynamic> body = {
      'amount': parsedAmount,
      'walletId': walletId,
    };
    
    if (reason.isNotEmpty) {
      body['reason'] = reason;
    }
    
    if (userId != null) {
      body['uid'] = userId;
    }
    
    body['payDay'] = selectedDate.toIso8601String();

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

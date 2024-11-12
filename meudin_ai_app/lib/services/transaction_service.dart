import 'package:meudin_ai_app/environment/environment.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/models/transaction.dart';
// import 'package:http/http.dart' as http;

class TransactionService {
  String apiUrl = Environment.apiUrl;
  // late UserService _userService;

  TransactionService() {
    // _userService = UserService();
  }

  Future<ResponseDto> getTransactionDtoList(
    String walletId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Uri url = Uri.parse('${apiUrl}getHomeDto');

    // final user = await _userService.getUser();

    // final userId = user?.uid;
    // final authToken = user?.token;

    ResponseDto responseDto;

    DateTime now = DateTime.now();
    final t1 = Transaction();
    t1.amount = 10000;
    t1.reason = 'Salário';
    t1.transactionId = 't1';
    t1.transactionDate = DateTime(now.year, now.month, 5);

    final t2 = Transaction();
    t2.amount = -3000;
    t2.reason = 'Video game';
    t2.categoryId = 'fun';
    t2.transactionId = 't2';
    t2.transactionDate = DateTime(now.year, now.month, 2);

    final t3 = Transaction();
    t3.amount = -1000;
    t3.reason = 'Revisão do carro';
    t3.categoryId = 'vehicle';
    t3.transactionId = 't3';
    t3.transactionDate = DateTime(now.year, now.month, 8);

    responseDto = ResponseDto();
    responseDto.success = true;
    responseDto.data = [
      t1,
      t2,
      t3,
    ];

    return responseDto;
  }
}

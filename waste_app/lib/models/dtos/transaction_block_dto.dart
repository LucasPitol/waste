import 'transaction_dto.dart';

class TransactionBlockDto {
  DateTime blockDate;
  List<TransactionDto> transactions;
  
  TransactionBlockDto() {
    this.transactions = [];
  }
}
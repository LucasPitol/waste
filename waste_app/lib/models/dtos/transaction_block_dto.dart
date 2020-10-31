import 'transaction_dto.dart';

class TransactionBlockDto {
  List<TransactionMonthBlockDto> transactionMonthBlockDtoList;
  bool reachedTheLimit;

  TransactionBlockDto() {
    this.transactionMonthBlockDtoList = [];
  }
}

class TransactionMonthBlockDto {
  DateTime blockDate;
  List<TransactionDto> transactions;

  TransactionMonthBlockDto() {
    this.transactions = [];
  }
}

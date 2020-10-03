import 'transaction_dto.dart';

class RevenueBlockDto {
  DateTime blockDate;
  bool isMonthly;
  double totalIncome;
  List<TransactionDto> revenues;
  
  RevenueBlockDto() {
    this.revenues = [];
  }
}
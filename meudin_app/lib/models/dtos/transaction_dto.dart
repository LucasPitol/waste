class TransactionDto {
  late String? transactionId;
  late String? reason;
  late DateTime? transactionDate;
  late double amount;
  late String? categoryId;

  TransactionDto() {}

  TransactionDto.fromJson(Map<String, dynamic> transactionMap) {
    
    this.transactionId = transactionMap['id'];
    this.amount = (transactionMap['amount']).toDouble();
    this.categoryId = transactionMap['categoryId'];
    this.reason = transactionMap['reason'];
    this.transactionDate = DateTime.parse(transactionMap['transactionDate']);

  }
}

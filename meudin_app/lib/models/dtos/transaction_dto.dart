class TransactionDto {
  late String? transactionId;
  late String? reason;
  late DateTime? transactionDate;
  late double? amount;
  late String? categoryId;

  TransactionDto({
    this.transactionId,
    this.reason,
    this.transactionDate,
    this.amount,
    this.categoryId,
  });
}

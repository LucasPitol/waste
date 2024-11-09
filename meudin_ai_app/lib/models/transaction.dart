class Transaction {
  late String? transactionId;
  late String? reason;
  late DateTime? transactionDate;
  late double amount;
  late String? categoryId;

  Transaction() {
    amount = 0;
  }
}

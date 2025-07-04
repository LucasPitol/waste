class Transaction {
  String? transactionId;
  String? reason;
  DateTime? transactionDate;
  double? amount;
  String? categoryId;

  Transaction();

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction()
      ..transactionId = json['transactionId'] as String?
      ..reason = json['reason'] as String?
      ..transactionDate = json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'])
          : null
      ..amount = json['amount'] != null ? (json['amount'] as num).toDouble() : null
      ..categoryId = json['categoryId'] as String?;
  }
}

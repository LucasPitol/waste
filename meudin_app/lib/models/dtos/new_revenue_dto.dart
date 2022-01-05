class NewRevenueDto {
  late String reason;
  late double amount;
  late String payDay;
  late String? uid;
  late String walletId;

  Map<String, dynamic> toJson() {
    return {
      'reason': this.reason,
      'amount': this.amount,
      'payDay': this.payDay,
      'uid': this.uid,
      'walletId': this.walletId,
    };
  }
}

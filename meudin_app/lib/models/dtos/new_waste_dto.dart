class NewWasteDto {
  late String reason;
  late double waste;
  late String categoryId;
  late String spendDate;
  late String? uid;
  late String walletId;

  Map<String, dynamic> toJson() {
    return {
      'reason': this.reason,
      'waste': this.waste,
      'categoryId': this.categoryId,
      'spendDate': this.spendDate,
      'uid': this.uid,
      'walletId': this.walletId,
    };
  }
}

class SpendItem {
  String uid;
  String reason;
  DateTime spendDate;
  double spent;
  String spendId;
  String walletId;
  String categoryId;

  SpendItem(
    this.uid,
    this.reason,
    this.spendDate,
    this.spent,
    this.spendId,
    this.walletId,
    this.categoryId,
  );
}

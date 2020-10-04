class Wallet {
  String id;
  DateTime creationDate;
  List<String> membersId;
  String name;
  String ownerId;
  double totalBalance;

  Wallet(this.id, this.creationDate, this.membersId, this.name, this.ownerId, this.totalBalance);
}
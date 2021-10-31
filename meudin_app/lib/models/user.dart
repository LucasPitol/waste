import 'abstract_model.dart';
import 'wallet.dart';

class User extends AbstractModel {
  late String name;
  late String email;

  late String currentWalletId;
  late List<Wallet> walletList;

  User() {
    walletList = [];
  }

  // User(DocumentSnapshot doc) {
  //   Map<String, dynamic> objMapp = doc.data();

  //   Timestamp creationDateTimestamp = objMapp['creationDate'];

  //   this.id = doc.id;
  //   this.name = objMapp['name'];
  //   this.email = objMapp['email'];
  //   this.creationDate = creationDateTimestamp.toDate();
  // }
}


import 'package:meudin_ai_app/models/abstract_model.dart';

import 'wallet.dart';

class User extends AbstractModel {
  late String displayName;
  late String email;

  late String currentWalletId;
  late List<Wallet> walletList;

  User() {
    walletList = [];
  }
}

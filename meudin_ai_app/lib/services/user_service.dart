import 'package:meudin_ai_app/models/user.dart';
import 'package:meudin_ai_app/models/wallet.dart';

class UserService {
  static User? currentUser;

  static User? mockCurrentUser() {
    var wallet1 = Wallet();
    wallet1.membersIds = ['1'];
    wallet1.name = 'Wallet 1';
    wallet1.id = '1';

    var wallet2 = Wallet();
    wallet2.membersIds = ['1', '2'];
    wallet2.name = 'Wallet 2';
    wallet2.id = '2';

    var user = User();
    user.currentWalletId = wallet1.id;
    user.displayName = 'Severaldo Messi';
    user.email = 'mail@ll.com';
    user.walletList = [
      wallet1,
      wallet2,
    ];
    user.id = '1';

    currentUser = user;

    return currentUser;
  }
}

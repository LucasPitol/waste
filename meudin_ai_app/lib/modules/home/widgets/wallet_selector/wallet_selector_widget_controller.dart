import 'package:get/get.dart';
import 'package:meudin_ai_app/models/wallet.dart';

class WalletSelectorController extends GetxController {
  switchWallet(String walletId) {
    Get.back(result: {
      'newWalletId': walletId,
      'createNewWallet': false,
    });
  }

  handleNewWalletPage() {
    Get.back(result: {
      'createNewWallet': true,
    });
  }

  showWalletMenu(Wallet wallet) {
    Get.back(result: {
      'walletId': wallet.id,
      'walletName': wallet.name,
      'action': 'menu',
    });
  }
}

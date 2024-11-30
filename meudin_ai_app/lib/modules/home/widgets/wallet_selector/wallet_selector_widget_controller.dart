import 'package:get/get.dart';

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
}

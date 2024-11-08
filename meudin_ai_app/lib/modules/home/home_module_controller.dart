import 'package:get/get.dart';
import 'package:meudin_ai_app/models/wallet.dart';

class HomeModuleController extends GetxController {
  late Wallet currentWallet;
  late bool isWalletOwner;
  late bool loading;

  @override
  void onInit() {
    loading = true;
    super.onInit();
  }

  HomeModuleController() {
    isWalletOwner = false;
  }
}

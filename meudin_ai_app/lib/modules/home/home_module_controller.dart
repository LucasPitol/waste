import 'package:flutter/material.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_selector/wallet_selector_widget.dart';
import 'package:meudin_ai_app/services/transaction_service.dart';
import 'package:meudin_ai_app/models/dtos/response_dto.dart';
import 'package:meudin_ai_app/services/user_service.dart';
import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/models/wallet.dart';
import 'package:meudin_ai_app/models/user.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';

class HomeModuleController extends GetxController {
  User? _user;
  late Wallet currentWallet;
  late bool isWalletOwner;
  late bool loading;
  late double monthRevenue;
  late double monthSpends;
  late double monthBalance;
  late DateTime startDate;
  late DateTime endDate;
  late List<Transaction> transactionDtoList;
  late List<Transaction> twoFirstTransactionDtoList;
  late TransactionService _transactionService;
  late UserService _userService;

  HomeModuleController() {
    _userService = UserService();
    // _user = UserService.currentUser;
    _user = UserService.mockCurrentUser();
    currentWallet = _user!.walletList
        .singleWhere((element) => element.id == _user!.currentWalletId);
    isWalletOwner = (currentWallet.ownerId == _user!.id);
    monthRevenue = 0.0;
    monthSpends = 0.0;
    monthBalance = 0.0;
    transactionDtoList = [];
    twoFirstTransactionDtoList = [];
    _transactionService = TransactionService();
  }

  @override
  void onInit() {
    super.onInit();
    loading = true;
    _fillStandardDate();
    updatePageData();
  }

  openWalletSelector() async {
    List<Wallet> userWallets = _user!.walletList;

    Map<String, dynamic>? newWalletOptions = await showModalBottomSheet(
        context: Get.context!,
        backgroundColor: Styles.whiteColor,
        builder: (builder) {
          return WalletSelectorWidget(
            walletList: userWallets,
          );
        });

    if (newWalletOptions != null) {
      if (newWalletOptions.containsKey('newWalletId') &&
          newWalletOptions['createNewWallet'] == false) {
        final newWalletId = newWalletOptions['newWalletId'];
        _switchCurrentWallet(newWalletId);
      }

      if (newWalletOptions['createNewWallet'] == true) {
        print('Create new wallet');
      }
    }
  }

  _switchCurrentWallet(String newWalletId) {
    Wallet walletTemp =
        _user!.walletList.singleWhere((element) => element.id == newWalletId);

    UserService.currentUser!.currentWalletId = newWalletId;

    bool isWalletOwnerTemp = (walletTemp.ownerId == _user!.id);

    currentWallet = walletTemp;
    isWalletOwner = isWalletOwnerTemp;

    update();

    updatePageData();
  }

  _fillStandardDate() {
    DateTime now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month, now.day, 59, 59, 59, 59);
  }

  updatePageData() async {
    loading = true;
    update();

    await _updateWallets();

    String walletId = currentWallet.id;

    ResponseDto res = await _transactionService.getTransactionDtoList(
      walletId,
      startDate,
      endDate,
    );

    loading = false;

    if (res.success) {
      transactionDtoList = res.data.isNotEmpty ? res.data : [];

      double totalAmountTemp = 0;
      double totalRevenueTemp = 0;
      double totalSpendTemp = 0;

      for (var element in transactionDtoList) {
        double amount = element.amount;

        if (amount > 0) {
          totalRevenueTemp = totalRevenueTemp + amount;
        } else {
          totalSpendTemp = totalSpendTemp + amount;
        }
      }

      totalAmountTemp = (totalRevenueTemp + totalSpendTemp);

      monthRevenue = totalRevenueTemp;
      monthSpends = totalSpendTemp;
      monthBalance = totalAmountTemp;

      twoFirstTransactionDtoList = transactionDtoList.take(2).toList();
    } else {
      // modal
    }

    update();
  }

  _updateWallets() async {
    await _userService.updateUserWallets();

    _user = UserService.currentUser;

    Wallet currentWalletTemp = _user!.walletList
        .singleWhere((element) => element.id == _user!.currentWalletId);

    bool isWalletOwnerTemp = (currentWalletTemp.ownerId == _user!.id);

    currentWallet = currentWalletTemp;
    isWalletOwner = isWalletOwnerTemp;

    update();
  }
}

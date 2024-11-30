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

  HomeModuleController() {
    // _user = UserService.currentUser;
    _user = UserService.mockCurrentUser();
    isWalletOwner = false;
    monthRevenue = 0.0;
    monthSpends = 0.0;
    monthBalance = 0.0;
    transactionDtoList = [];
    twoFirstTransactionDtoList = [];
    _transactionService = TransactionService();
    currentWallet = Wallet();
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
    print(newWalletId);
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
    // mock
    currentWallet.name = 'Carteira pessoal';
    currentWallet.ownerId = 'abc';
    currentWallet.id = 'wal1';
    currentWallet.membersIds = ['wal1'];
  }
}

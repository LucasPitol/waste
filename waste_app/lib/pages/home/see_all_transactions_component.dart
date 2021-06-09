import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:waste_app/models/dtos/transaction_block_dto.dart';
import 'package:waste_app/models/dtos/transaction_dto.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/transactions_service.dart';
import 'package:waste_app/services/wallet_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class SeeAllTransactionsComponent extends StatefulWidget {
  Wallet currentWallet;
  SeeAllTransactionsComponent(this.currentWallet);
  @override
  _SeeAllTransactionsComponentState createState() =>
      _SeeAllTransactionsComponentState(currentWallet);
}

class _SeeAllTransactionsComponentState
    extends State<SeeAllTransactionsComponent> {
  String localeLanguage =
      AuthService.currentUser.language == Constants.languages[0]
          ? Constants.ptLanguage
          : Constants.enLanguage;
  UserDto userDto = AuthService.currentUser;
  TransactionService transactionService;
  WalletService walletService;
  AuthService authService;

  bool isPtLanguage;
  bool transactionsLoading = true;
  bool balanceLoading = true;
  List<TransactionMonthBlockDto> transactionByMonthBlockList = [];
  Wallet currentWallet;
  bool reachedTheLimit = false;

  _SeeAllTransactionsComponentState(Wallet currentWallet) {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.transactionService = TransactionService();
    this.walletService = WalletService();
    this.authService = AuthService();
    this.currentWallet = currentWallet;
  }

  void initState() {
    super.initState();
    this.updatePageContent();
  }

  updatePageContent() {
    this._getTotalBalance();
    this._getTransactions();
  }

  _getTransactions() {
    setState(() {
      this.transactionsLoading = true;
      this.reachedTheLimit = false;
    });

    String walletId = currentWallet.id;

    this.transactionService.getTransactionsByWalletId(walletId).then((value) {
      this.transactionByMonthBlockList = value.transactionMonthBlockDtoList;

      this.reachedTheLimit = value.reachedTheLimit;

      setState(() {
        this.transactionsLoading = false;
      });
    });
  }

  _getOut() {
    Navigator.pop(context);
  }

  _getTotalBalance() {
    setState(() {
      this.balanceLoading = false;
    });
  }

  Widget createTileForTransactionsBlock(TransactionMonthBlockDto item) {
    String blockMonth =
        DateFormat.MMMM(this.localeLanguage).format(item.blockDate);

    return Container(
      margin: EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          Container(
            alignment: Alignment.topLeft,
            margin: EdgeInsets.only(bottom: 10),
            child: Text(
              blockMonth,
              style: Styles.poppinsTextGrey,
            ),
          ),
          Container(
            child: Column(
              children: item.transactions
                  .map((transaction) => createTileForTransactions(transaction))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget createTileForTransactions(TransactionDto item) {
    String transactionDate =
        DateFormat.Md(this.localeLanguage).format(item.transactionDate) +
            ', ' +
            DateFormat.Hm(this.localeLanguage).format(item.transactionDate);

    String ammount = item.amount > 0
        ? '+' + Constants.getAmountFormated(item.amount)
        : Constants.getAmountFormated(item.amount);

    return Container(
      child: ListTile(
        trailing: Text(
          ammount,
          style: TextStyle(
            color: Colors.grey.shade100,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        title: Text(
          item.reason,
          style: TextStyle(
              color: Colors.grey.shade100,
              fontSize: 18,
              fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          transactionDate,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Styles.mainBackgroundColor,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Container(
                  child: Stack(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          isPtLanguage ? 'Transações' : 'Transacions',
                          style: TextStyle(
                            color: Colors.grey.shade100,
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 15),
                              child: InkWell(
                                borderRadius: Styles.circularBorderRadius,
                                onTap: () {
                                  this.updatePageContent();
                                },
                                child: Icon(
                                  Icons.refresh,
                                  color: Colors.grey.shade100,
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: Styles.circularBorderRadius,
                              onTap: () {
                                _getOut();
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.grey.shade100,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: balanceLoading
                      ? Constants.getDefaultLoadingWidget(context)
                      : Column(
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(top: 20),
                              child: Text(
                                isPtLanguage ? 'Caixa' : 'Balance',
                                style: TextStyle(
                                  color: Colors.grey.shade100,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              alignment: Alignment.topLeft,
                              child: Text(
                                Constants.getAmountFormated(
                                    currentWallet.totalBalance),
                                style: TextStyle(
                                  color: Colors.grey.shade100,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: transactionsLoading
                      ? Constants.getDefaultLoadingWidget(context)
                      : Column(
                          children: transactionByMonthBlockList
                              .map((item) =>
                                  createTileForTransactionsBlock(item))
                              .toList(),
                        ),
                ),
                this.reachedTheLimit
                    ? Container(
                        alignment: Alignment.bottomCenter,
                        margin: EdgeInsets.only(bottom: 20),
                        child: Text(
                          isPtLanguage
                              ? 'Limitando até ' +
                                  Constants.maximumTransactionsDiplayCount
                                      .toString() +
                                  ' transações, em breve o limite será estendido'
                              : 'limiting up to ' +
                                  Constants.maximumTransactionsDiplayCount
                                      .toString() +
                                  ' transactions, the limit will soon be extended',
                          style: TextStyle(
                            color: Colors.grey.shade100,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

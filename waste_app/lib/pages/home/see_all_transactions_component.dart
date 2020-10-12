import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:waste_app/models/dtos/transaction_dto.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/transactions_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

class SeeAllTransactionsComponent extends StatefulWidget {
  @override
  _SeeAllTransactionsComponentState createState() =>
      _SeeAllTransactionsComponentState();
}

class _SeeAllTransactionsComponentState
    extends State<SeeAllTransactionsComponent> {
  String localeLanguage =
      AuthService.currentUser.language == Constants.languages[0]
          ? Constants.ptLanguage
          : Constants.enLanguage;
  UserDto userDto = AuthService.currentUser;
  TransactionService transactionService;
  AuthService authService;

  bool transactionsLoading = true;
  bool ballanceLoading = true;
  List<TransactionDto> transactions = [];

  _SeeAllTransactionsComponentState() {
    this.transactionService = TransactionService();
    this.authService = AuthService();
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
      resizeToAvoidBottomPadding: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Container(
                  child: ballanceLoading
                      ? Constants.getDefaultLoadingWidget(context)
                      : Column(
                          children: [Text('Saldo')],
                        ),
                ),
                Container(
                  child: transactionsLoading
                      ? Constants.getDefaultLoadingWidget(context)
                      : Column(
                          children: transactions
                              .map((item) => createTileForTransactions(item))
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

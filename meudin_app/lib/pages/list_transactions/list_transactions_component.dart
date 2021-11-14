import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_app/models/dtos/transaction_dto.dart';
import 'package:meudin_app/utils/styles.dart';
import 'package:meudin_app/utils/utils.dart';

class ListTransactionsComponent extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final List<TransactionDto> transactionDtoList;

  ListTransactionsComponent({
    required this.startDate,
    required this.endDate,
    required this.transactionDtoList,
  });

  @override
  _ListTransactionsComponentState createState() =>
      _ListTransactionsComponentState(
        startDate: startDate,
        endDate: endDate,
        transactionDtoList: transactionDtoList,
      );
}

class _ListTransactionsComponentState extends State<ListTransactionsComponent> {
  final DateTime startDate;
  final DateTime endDate;
  final List<TransactionDto> transactionDtoList;

  _ListTransactionsComponentState({
    required this.startDate,
    required this.endDate,
    required this.transactionDtoList,
  });

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      alignment: Alignment.topRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transações',
                  style: Styles.montTextTitle,
                ),
                Text(
                  Utils.formatDateMMMdeYYYY(startDate),
                  style: Styles.montSubText,
                ),
              ],
            ),
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.times,
              color: Styles.mainTextColor,
              size: 22,
            ),
            onPressed: () {
              _goBack(false);
            },
          ),
        ],
      ),
    );
  }

  _goBack(bool refresh) {
    Navigator.pop(context, refresh);
  }

  Widget _buildTransactionList() {
    return transactionDtoList.isEmpty
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 40),
            child: Text('Sem transações nesta data', style: Styles.montText),
          )
        : SizedBox(
            child: Column(
              children: transactionDtoList.map((e) {
                return _buildTransactionTile(e);
              }).toList(),
            ),
          );
  }

  Widget _buildTransactionTile(TransactionDto item) {
    String title = item.reason ?? '';
    String date = Utils.formatDateDDMM(item.transactionDate);
    String amountStr = Utils.formatAmount(item.amount);

    if (item.amount! > 0) {
      amountStr = '+' + amountStr;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Styles.montText,
                ),
                Text(
                  date,
                  style: Styles.montSubText,
                )
              ],
            ),
          ),
          Text(
            amountStr,
            style: Styles.montText,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            _buildAppBar(),
            const SizedBox(
              width: double.infinity,
              height: 10,
            ),
            _buildTransactionList(),
          ],
        ),
      )),
    );
  }
}

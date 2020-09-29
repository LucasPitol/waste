import 'package:waste_app/models/forms/new_revenue_form.dart';
import 'package:waste_app/services/revenues_service.dart';
import 'package:waste_app/services/wallet_service.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:flutter/material.dart';
import 'package:waste_app/utils/styles.dart';

class NewRevenueComponent extends StatefulWidget {
  @override
  _NewRevenueComponenState createState() => _NewRevenueComponenState();
}

class _NewRevenueComponenState extends State<NewRevenueComponent> {
  var userDto = AuthService.currentUser;

  bool isPtLanguage;
  List<Wallet> wallets;
  String dropdownWalletValue;
  final _formKey = GlobalKey<FormState>();
  NewRevenueForm newRevenueForm;
  bool loading = false;

  RevenuesService revenuesService;
  WalletService walletService;

  _NewRevenueComponenState() {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.newRevenueForm = NewRevenueForm();
    this.revenuesService = RevenuesService();
    this.walletService = WalletService();
  }

  void initState() {
    super.initState();
    this._getUserWallets();
  }

  void _getUserWallets() {
    wallets = this.walletService.getUserWalletsLocal();

    this.dropdownWalletValue = this.walletService.getCurrentWalletId();
  }

  void switchWallets(String walletId) {
    setState(() {
      this.dropdownWalletValue = walletId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      resizeToAvoidBottomPadding: true,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.deepPurple,
              child: Stack(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(right: 20, top: 10),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context, false);
                      },
                      child: Icon(
                        Icons.close,
                        color: Styles.mainBackgroundColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(left: 20, top: 10),
              child: Text(
                this.userDto.language == Constants.languages[0]
                    ? 'Nova receita'
                    : 'New revenue',
                style: TextStyle(
                  color: Styles.mainBackgroundColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 50),
              decoration: Styles.containerDecoration,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 15, left: 20, right: 20),
                        child: TextFormField(
                          style: TextStyle(color: Colors.grey.shade100),
                          maxLength: 50,
                          controller: newRevenueForm.reason,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value.isEmpty) {
                              return Constants.getDefaultEmptyFieldMsg(
                                  isPtLanguage);
                            }
                            return null;
                          },
                          decoration: this.userDto.language ==
                                  Constants.languages[0]
                              ? Styles.getTextFieldDecorationUnderline('Motivo')
                              : Styles.getTextFieldDecorationUnderline(
                                  'Reason'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/services.dart';
import 'package:waste_app/models/forms/new_revenue_form.dart';
import 'package:waste_app/pages/shared/loading_block.dart';
import 'package:waste_app/services/transactions_service.dart';
import 'package:waste_app/services/wallet_service.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewRevenueComponent extends StatefulWidget {
  @override
  _NewRevenueComponenState createState() => _NewRevenueComponenState();
}

class _NewRevenueComponenState extends State<NewRevenueComponent> {
  var userDto = AuthService.currentUser;
  String localeLanguage =
      AuthService.currentUser.language == Constants.languages[0]
          ? Constants.ptLanguage
          : Constants.enLanguage;

  bool isPtLanguage;
  List<Wallet> wallets;
  String dropdownWalletValue;
  final _formKey = GlobalKey<FormState>();
  NewRevenueForm newRevenueForm;
  bool loading = false;

  TransactionService transactionService;
  WalletService walletService;

  _NewRevenueComponenState() {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.newRevenueForm = NewRevenueForm();
    this.transactionService = TransactionService();
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

  Future<void> _openDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: this.newRevenueForm.payDay,
        firstDate: DateTime(2000, 8),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              primaryColor: Colors.deepPurple,
              accentColor: Colors.deepPurple.shade900,
              colorScheme: ColorScheme.dark(
                primary: Colors.deepPurple,
                background: Styles.mainBackgroundColor,
              ),
              buttonTheme: ButtonThemeData(
                textTheme: ButtonTextTheme.primary,
              ),
            ),
            child: child,
          );
        });
    if (picked != null)
      setState(() {
        this.newRevenueForm.payDay = picked;
      });
  }

  _saveNewRevenue() async {
    setState(() {
      this.loading = true;
    });

    FocusScope.of(context).unfocus();

    this.newRevenueForm.walletId = this.dropdownWalletValue;
    var success = await this.transactionService.saveNewRevenue(newRevenueForm);

    setState(() {
      this.loading = false;
    });

    if (success) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.deepPurple,
      statusBarIconBrightness: Brightness.dark,
    ));
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
                          decoration: isPtLanguage
                              ? Styles.getTextFieldDecorationUnderline('Motivo')
                              : Styles.getTextFieldDecorationUnderline(
                                  'Reason'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: 10, bottom: 10, left: 20, right: 20),
                        child: TextFormField(
                          style: TextStyle(color: Colors.grey.shade100),
                          controller: newRevenueForm.revenueValue,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value.isEmpty) {
                              return Constants.getDefaultEmptyFieldMsg(
                                  isPtLanguage);
                            }
                            return null;
                          },
                          decoration: isPtLanguage
                              ? Styles.getTextFieldDecorationUnderline(
                                  'Quantia')
                              : Styles.getTextFieldDecorationUnderline(
                                  'Revenue'),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: 30, left: 20, bottom: 20, right: 10),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                isPtLanguage ? 'Data:' : 'Pay day:',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _openDatePicker(context);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  DateFormat.yMd(this.localeLanguage)
                                      .format(this.newRevenueForm.payDay),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade100),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        // margin: EdgeInsets.only(top: 10),
                        child: DropdownButton<String>(
                          dropdownColor: Styles.mainBackgroundColor,
                          value: dropdownWalletValue,
                          icon: Icon(Icons.keyboard_arrow_down),
                          iconSize: 24,
                          elevation: 16,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              color: Colors.grey.shade100,
                              fontSize: 16,
                            ),
                          ),
                          underline: Container(
                            height: 1,
                            color: Colors.grey.shade900,
                          ),
                          onChanged: (String newValue) {
                            switchWallets(newValue);
                          },
                          items: wallets
                              .map<DropdownMenuItem<String>>((Wallet item) {
                            return DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(item.name),
                            );
                          }).toList(),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 40, left: 20, right: 20),
                        child: ButtonTheme(
                          minWidth: double.infinity,
                          height: 50,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: Styles.defaultTextFieldBorderRadius,
                            ),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                _saveNewRevenue();
                              }
                            },
                            color: Colors.deepPurple,
                            child: Text(
                              isPtLanguage ? 'Salvar' : 'Save',
                              style: TextStyle(
                                  color: Styles.mainBackgroundColor,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            LoadingBlock(this.loading),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:waste_app/models/edit_waste_form.dart';
import 'package:waste_app/pages/shared/loading_block.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/services/spends_service.dart';
import 'package:waste_app/services/wallet_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/material.dart';

class EditSpendComponent extends StatefulWidget {
  String spendId;
  EditSpendComponent(this.spendId);
  @override
  _EditSpendComponenState createState() => _EditSpendComponenState(spendId);
}

class _EditSpendComponenState extends State<EditSpendComponent> {
  UserDto userDto = AuthService.currentUser;
  String dropdownWalletValue;
  List<Wallet> wallets;
  EditWasteForm editWasteForm;
  bool loading = false;
  String spendId;
  final _editSpendFormKey = GlobalKey<FormState>();

  WalletService walletService;
  SpendsService spendsService;
  AuthService authService;

  _EditSpendComponenState(String spendId) {
    this.spendId = spendId;
    this.walletService = WalletService();
    this.editWasteForm = EditWasteForm();
    this.spendsService = SpendsService();
    this.authService = AuthService();
  }

  void initState() {
    super.initState();
    this._getUserWallets();
  }

  void _selectDate() {
    DatePicker.showDateTimePicker(
      context,
      theme: DatePickerTheme(
        doneStyle: TextStyle(color: Colors.deepPurple),
      ),
      locale: LocaleType.pt,
      showTitleActions: true,
      minTime: DateTime(1810, 1, 1),
      maxTime: DateTime.now().add(
        Duration(days: 35),
      ),
      onChanged: (newDate) {
        setState(
          () {
            this.editWasteForm.spendDate = newDate;
          },
        );
      },
      onConfirm: (newDate) {
        setState(
          () {
            this.editWasteForm.spendDate = newDate;
          },
        );
      },
    );
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

  _updateWaste() {
    print('update');
  }

  _deleteWaste() {
    print('delete');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
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
                        color: Colors.white,
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
                    ? 'Editar desperdício'
                    : 'Edit waste',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
                  key: _editSpendFormKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            top: 20, bottom: 10, left: 20, right: 20),
                        child: TextFormField(
                          maxLength: 50,
                          controller: editWasteForm.reason,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value.isEmpty) {
                              return Constants.getDefaultEmptyFieldMsg(
                                  userDto.language);
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
                      Container(
                        margin: EdgeInsets.only(
                            top: 10, bottom: 10, left: 20, right: 20),
                        child: TextFormField(
                          controller: editWasteForm.waste,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value.isEmpty) {
                              return Constants.getDefaultEmptyFieldMsg(
                                  userDto.language);
                            }
                            return null;
                          },
                          decoration: this.userDto.language ==
                                  Constants.languages[0]
                              ? Styles.getTextFieldDecorationUnderline(
                                  'Desperdício')
                              : Styles.getTextFieldDecorationUnderline('Waste'),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin:
                                EdgeInsets.only(top: 20, bottom: 20, right: 10),
                            child: Text(
                              'Data:',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _selectDate();
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: 20, bottom: 20, left: 10),
                              child: Text(
                                DateFormat.yMd(Constants.ptLanguage)
                                    .add_jm()
                                    .format(this.editWasteForm.spendDate),
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        child: DropdownButton<String>(
                          value: dropdownWalletValue,
                          icon: Icon(Icons.keyboard_arrow_down),
                          iconSize: 24,
                          elevation: 16,
                          style: GoogleFonts.quicksand(
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          underline: Container(
                            height: 1,
                            color: Colors.white10,
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
                              if (_editSpendFormKey.currentState.validate()) {
                                _updateWaste();
                              }
                            },
                            color: Colors.deepPurple,
                            child: Text(
                              'Atualizar',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 40),
                        child: FlatButton(
                          onPressed: _deleteWaste,
                          child: Text(
                            'Excluir',
                            style: TextStyle(color: Colors.red),
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

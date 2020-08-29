import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:waste_app/pages/shared/loading_block.dart';
import 'package:waste_app/models/spending_category.dart';
import 'package:waste_app/services/spends_service.dart';
import 'package:waste_app/services/wallet_service.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/models/new_waste_form.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'category_bottom_sheet_component.dart';

class NewSpendComponent extends StatefulWidget {
  @override
  _NewSpendComponenState createState() => _NewSpendComponenState();
}

class _NewSpendComponenState extends State<NewSpendComponent> {
  String localeLanguage =
      AuthService.currentUser.language == Constants.languages[0]
          ? Constants.ptLanguage
          : Constants.enLanguage;
  UserDto userDto = AuthService.currentUser;

  List<Wallet> wallets;
  List<SpendingCategory> spendingCategoryList;
  String dropdownWalletValue;
  final _formKey = GlobalKey<FormState>();
  NewWasteForm newWasteForm;
  bool loading = false;

  WalletService walletService;
  SpendsService spendsService;
  AuthService authService;

  SpendingCategory categorySelected;

  _NewSpendComponenState() {
    this.walletService = WalletService();
    this.newWasteForm = NewWasteForm();
    this.spendsService = SpendsService();
    this.authService = AuthService();
    this.spendingCategoryList = List<SpendingCategory>();
  }

  void initState() {
    super.initState();
    this._getUserWallets();
    this._getSpendingCategories();
  }

  Future<void> _getSpendingCategories() async {
    List<SpendingCategory> listTemp =
        await this.spendsService.getSpendingCategories();

    setState(() {
      this.spendingCategoryList = listTemp;
      this.categorySelected =
          listTemp.where((element) => element.value == 'others').first;
    });
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

  void _selectDate() {
    DatePicker.showDateTimePicker(
      context,
      theme: DatePickerTheme(
        doneStyle: TextStyle(color: Colors.deepPurple),
      ),
      locale: this.userDto.language == Constants.languages[0]
          ? LocaleType.pt
          : LocaleType.en,
      showTitleActions: true,
      minTime: DateTime(1810, 1, 1),
      maxTime: DateTime.now().add(
        Duration(days: 35),
      ),
      onChanged: (newDate) {
        setState(
          () {
            this.newWasteForm.spendDate = newDate;
          },
        );
      },
      onConfirm: (newDate) {
        setState(
          () {
            this.newWasteForm.spendDate = newDate;
          },
        );
      },
    );
  }

  void changeCategory(String newValue) {
    if (newValue != null) {
      var categorySelectedTemp =
          this.spendingCategoryList.where((element) => element.value == newValue).first;
      setState(() {
        this.categorySelected = categorySelectedTemp;
      });
    }
  }

  void _openCategoryBottomSheet() {
    Future<String> selectedValue = showModalBottomSheet(
        context: context,
        builder: (builder) {
          return CategoryBottomSheetComponent(this.spendingCategoryList, categorySelected.value);
        });
        selectedValue.then((value) => this.changeCategory(value));
  }

  Future<void> _saveNewWaste() async {
    setState(() {
      this.loading = true;
    });

    FocusScope.of(context).unfocus();

    this.authService.userExists(context);

    this.newWasteForm.walletId = dropdownWalletValue;
    this.newWasteForm.categoryId = categorySelected.id;
    var success = await this.spendsService.waste(newWasteForm);

    setState(() {
      this.loading = false;
    });

    if (success) {
      Navigator.pop(context, true);
    }
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
                    ? 'Novo gasto'
                    : 'New waste',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
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
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 15, left: 20, right: 20),
                        child: TextFormField(
                          maxLength: 50,
                          controller: newWasteForm.reason,
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
                          controller: newWasteForm.waste,
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
                      Container(
                        margin: EdgeInsets.only(
                            top: 20, bottom: 10, left: 20, right: 20),
                        child: Stack(
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                this.userDto.language == Constants.languages[0]
                                    ? 'Categoria:'
                                    : 'Category:',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _openCategoryBottomSheet();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: categorySelected != null
                                    ? Text(
                                        this.userDto.language ==
                                                Constants.languages[0]
                                            ? categorySelected.displayNamePt
                                            : categorySelected.displayNameEn,
                                        style: TextStyle(fontSize: 16),
                                      )
                                    : Container(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        height: 1,
                        child: Divider(),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: 30, left: 20, bottom: 20, right: 10),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                this.userDto.language == Constants.languages[0]
                                    ? 'Data:'
                                    : 'Date:',
                                style: TextStyle(color: Colors.grey.shade600,fontSize: 16),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _selectDate();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  DateFormat.yMd(this.localeLanguage)
                                      .add_jm()
                                      .format(this.newWasteForm.spendDate),
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: DropdownButton<String>(
                          value: dropdownWalletValue,
                          icon: Icon(Icons.keyboard_arrow_down),
                          iconSize: 24,
                          elevation: 16,
                          style: GoogleFonts.poppins(
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
                              if (_formKey.currentState.validate()) {
                                _saveNewWaste();
                              }
                            },
                            color: Colors.deepPurple,
                            child: Text(
                              this.userDto.language == Constants.languages[0]
                                  ? 'Salvar'
                                  : 'Save',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
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

import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:waste_app/models/forms/edit_waste_form.dart';
import 'package:waste_app/models/dtos/spend_item_dto.dart';
import 'package:waste_app/models/spending_category.dart';
import 'package:waste_app/pages/dialogs/confirm_dialog.dart';
import 'package:waste_app/pages/new_spend/category_bottom_sheet_component.dart';
import 'package:waste_app/pages/shared/loading_block.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/models/user_dto.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/services/spending_categories_service.dart';
import 'package:waste_app/services/transactions_service.dart';
import 'package:waste_app/services/wallet_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/material.dart';

class EditSpendComponent extends StatefulWidget {
  SpendItem spend;
  EditSpendComponent(this.spend);
  @override
  _EditSpendComponenState createState() => _EditSpendComponenState(spend);
}

class _EditSpendComponenState extends State<EditSpendComponent> {
  String localeLanguage =
      AuthService.currentUser.language == Constants.languages[0]
          ? Constants.ptLanguage
          : Constants.enLanguage;
  UserDto userDto = AuthService.currentUser;
  String languageCode;
  String currentWalletId;
  Wallet currentWallet;
  List<Wallet> wallets;
  EditWasteForm editWasteForm;
  EditWasteForm previousWasteForm;
  bool loading = false;
  bool isPtLanguage;
  SpendItem spend;
  List<SpendingCategory> spendingCategoryList;
  SpendingCategory categorySelected;
  final _editSpendFormKey = GlobalKey<FormState>();

  WalletService walletService;
  TransactionService transactionService;
  SpendingCategoriesService spendingCategoriesService;
  AuthService authService;

  _EditSpendComponenState(SpendItem spend) {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.languageCode = this.userDto.language;
    this.spend = spend;
    this.walletService = WalletService();
    this.editWasteForm = EditWasteForm();
    this.previousWasteForm = EditWasteForm();
    this.transactionService = TransactionService();
    this.spendingCategoriesService = SpendingCategoriesService();
    this.authService = AuthService();
    this.spendingCategoryList = List<SpendingCategory>();
  }

  void initState() {
    super.initState();
    this._getUserWallets();
    this._buildForm();
    this._getSpendingCategories();
  }

  Future<void> _getSpendingCategories() async {
    List<SpendingCategory> listTemp =
        await this.spendingCategoriesService.getSpendingCategories();

    String categoryId = spend.categoryId;

    setState(() {
      this.spendingCategoryList = listTemp;
      this.categorySelected = categoryId != null
          ? listTemp.where((element) => element.id == categoryId).first
          : listTemp.where((element) => element.value == 'others').first;
    });
  }

  void changeCategory(String newValue) {
    if (newValue != null) {
      var categorySelectedTemp = this
          .spendingCategoryList
          .where((element) => element.value == newValue)
          .first;
      setState(() {
        this.categorySelected = categorySelectedTemp;
      });
    }
  }

  void _buildForm() {
    editWasteForm.reason.text = spend.reason;
    double wastePositive = spend.spent * (-1);
    editWasteForm.waste.text = (wastePositive * 10).toString();
    editWasteForm.spendDate = spend.spendDate;
    editWasteForm.spendId = spend.spendId;
    editWasteForm.categoryId = spend.categoryId;

    previousWasteForm.reason.text = spend.reason;
    double previousWastePositive = spend.spent * (-1);
    previousWasteForm.waste.text = (previousWastePositive * 10).toString();
    previousWasteForm.spendDate = spend.spendDate;
    previousWasteForm.spendId = spend.spendId;
    previousWasteForm.categoryId = spend.categoryId;
  }

  void _selectDate() {
    DatePicker.showDateTimePicker(
      context,
      theme: DatePickerTheme(
        doneStyle: TextStyle(color: Colors.deepPurple),
        backgroundColor: Styles.mainBackgroundColor,
        cancelStyle: TextStyle(color: Colors.grey),
        itemStyle: TextStyle(color: Colors.grey.shade100),
      ),
      locale: this.languageCode == Constants.languages[0]
          ? LocaleType.pt
          : LocaleType.en,
      currentTime: spend.spendDate,
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

    this.currentWalletId = this.walletService.getCurrentWalletId();

    this.currentWallet = wallets.where((w) => currentWalletId == w.id).first;
  }

  Future<void> _updateWaste() async {
    setState(() {
      this.loading = true;
    });

    FocusScope.of(context).unfocus();

    this.editWasteForm.walletId = this.currentWalletId;

    this.editWasteForm.categoryId = categorySelected.id;

    var success = await this
        .transactionService
        .updateWaste(editWasteForm, previousWasteForm);

    setState(() {
      this.loading = false;
    });

    if (success) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteWaste() async {
    String title = this.languageCode == Constants.languages[0]
        ? 'Excluir desperdício?'
        : 'Delete waste?';

    String subtitle = this.languageCode == Constants.languages[0]
        ? 'Não será possível recuperar o gasto'
        : 'Won\'t be able to recover it';

    bool delete = await _openConfirmDialog(title, subtitle);

    if (delete != null && delete) {
      setState(() {
        this.loading = true;
      });

      double spent = spend.spent * -1;

      var success = await this
          .transactionService
          .deleteWaste(spend.spendId, spend.categoryId, currentWalletId, spent);

      if (success) {
        Navigator.pop(context, true);
      }
    }
  }

  void _openCategoryBottomSheet() {
    Future<String> selectedValue = showModalBottomSheet(
        context: context,
        builder: (builder) {
          return CategoryBottomSheetComponent(
              this.spendingCategoryList, categorySelected.value);
        });
    selectedValue.then((value) => this.changeCategory(value));
  }

  Future<bool> _openConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
        context: context,
        builder: (builder) {
          return ConfirmDialogComponent(title, content);
        });
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
                    ? 'Editar desperdício'
                    : 'Edit waste',
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
                  key: _editSpendFormKey,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                            top: 20, bottom: 10, left: 20, right: 20),
                        child: TextFormField(
                          style: TextStyle(color: Colors.grey.shade100),
                          maxLength: 50,
                          controller: editWasteForm.reason,
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
                      Container(
                        margin: EdgeInsets.only(
                            top: 10, bottom: 10, left: 20, right: 20),
                        child: TextFormField(
                          style: TextStyle(color: Colors.grey.shade100),
                          controller: editWasteForm.waste,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value.isEmpty) {
                              return Constants.getDefaultEmptyFieldMsg(
                                  isPtLanguage);
                            }
                            return null;
                          },
                          decoration: this.languageCode ==
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
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
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
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey.shade100),
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
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 16),
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
                                      .format(this.editWasteForm.spendDate),
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
                        margin: EdgeInsets.only(top: 10),
                        child: Text(
                          currentWallet.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade100,
                            fontWeight: FontWeight.w500,
                          ),
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
                              this.languageCode == Constants.languages[0]
                                  ? 'Atualizar'
                                  : 'Update',
                              style: TextStyle(
                                  color: Styles.mainBackgroundColor,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 40),
                        child: FlatButton(
                          onPressed: _deleteWaste,
                          child: Text(
                            this.languageCode == Constants.languages[0]
                                ? 'Excluir'
                                : 'Delete',
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

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
import 'package:waste_app/services/spends_service.dart';
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
  String dropdownWalletValue;
  List<Wallet> wallets;
  EditWasteForm editWasteForm;
  bool loading = false;
  SpendItem spend;
  List<SpendingCategory> spendingCategoryList;
  SpendingCategory categorySelected;
  final _editSpendFormKey = GlobalKey<FormState>();

  WalletService walletService;
  SpendsService spendsService;
  SpendingCategoriesService spendingCategoriesService;
  AuthService authService;

  _EditSpendComponenState(SpendItem spend) {
    this.languageCode = this.userDto.language;
    this.spend = spend;
    this.walletService = WalletService();
    this.editWasteForm = EditWasteForm();
    this.spendsService = SpendsService();
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
    editWasteForm.waste.text = (spend.spent * 10).toString();
    editWasteForm.spendDate = spend.spendDate;
    editWasteForm.spendId = spend.spendId;
    editWasteForm.categoryId = spend.categoryId;
  }

  void _selectDate() {
    DatePicker.showDateTimePicker(
      context,
      theme: DatePickerTheme(
        doneStyle: TextStyle(color: Colors.deepPurple),
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

    this.dropdownWalletValue = this.walletService.getCurrentWalletId();
  }

  void switchWallets(String walletId) {
    setState(() {
      this.dropdownWalletValue = walletId;
    });
  }

  Future<void> _updateWaste() async {
    setState(() {
      this.loading = true;
    });

    FocusScope.of(context).unfocus();

    this.editWasteForm.walletId = dropdownWalletValue;

    this.editWasteForm.categoryId = categorySelected.id;

    var success = await this.spendsService.updateWaste(editWasteForm, spend.categoryId);

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

      var success = await this.spendsService.deleteWaste(spend.spendId, spend.categoryId);

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
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 16),
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
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 16),
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
                              if (_editSpendFormKey.currentState.validate()) {
                                _updateWaste();
                              }
                            },
                            color: Colors.deepPurple,
                            child: Text(
                              this.languageCode == Constants.languages[0]
                                  ? 'Atualizar'
                                  : 'Update',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
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

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:meudin_app/models/forms/new_waste_form.dart';
import 'package:meudin_app/models/spending_category.dart';
import 'package:meudin_app/models/user.dart';
import 'package:meudin_app/models/wallet.dart';
import 'package:meudin_app/pages/shared/info_bottom_sheet_widget.dart';
import 'package:meudin_app/pages/shared/loading_block.dart';
import 'package:meudin_app/services/spending_category_service.dart';
import 'package:meudin_app/services/transaction_service.dart';
import 'package:meudin_app/services/user_service.dart';
import 'package:meudin_app/utils/constants.dart';
import 'package:meudin_app/utils/styles.dart';
import 'package:meudin_app/utils/utils.dart';

import 'category_bottom_sheet_component.dart';

class NewSpendComponent extends StatefulWidget {
  @override
  _NewSpendComponentState createState() => _NewSpendComponentState();
}

class _NewSpendComponentState extends State<NewSpendComponent> {
  final _formKey = GlobalKey<FormState>();
  User? _user = UserService.currentUser;

  late SpendingCategoryService _spendingCategoriesService;
  late TransactionService _transactionService;
  late NewWasteForm _newWasteForm;

  bool loading = false;
  late Wallet _wallet;
  SpendingCategory? _categorySelected;
  late List<SpendingCategory> _spendingCategoryList;

  _NewSpendComponentState() {
    _spendingCategoriesService = SpendingCategoryService();
    _spendingCategoryList = <SpendingCategory>[];
    _transactionService = TransactionService();
    _newWasteForm = NewWasteForm();
  }

  @override
  void initState() {
    super.initState();
    _getUserWallets();
    _getSpendingCategories();
  }

  Future<void> _getSpendingCategories() async {
    List<SpendingCategory> listTemp = <SpendingCategory>[];

    _spendingCategoriesService.getSpendingCategories().then((res) {
      if (res.success) {
        listTemp = res.data;

        setState(() {
          _spendingCategoryList = listTemp;
          _categorySelected =
              listTemp.singleWhere((element) => element.value == 'others');
        });
      } else {
        _goBack(true);
      }
    });
  }

  _saveNewWaste() {
    setState(() {
      loading = true;
    });

    FocusScope.of(context).unfocus();

    _newWasteForm.walletId = _wallet.id;
    _newWasteForm.uid = _user!.id;
    _newWasteForm.categoryId = _categorySelected!.id;

    _transactionService.saveNewWaste(_newWasteForm).then((res) {
      if (res.success) {
        _goBack(true);
      } else {
        if (res.errorMsg.isNotEmpty) {
          String title = 'Ops...';
          String message = res.errorMsg;

          _openInfoBottomSheet(title, message);
        } else {
          String title = 'Ops...';
          String message =
              'Não foi possível comunicar-se com o servidor, tente novamente mais tarde';

          _openInfoBottomSheet(title, message);
        }
      }
      setState(() {
        loading = false;
      });
    });
  }

  void _openInfoBottomSheet(String title, String message) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Styles.cardColor,
        builder: (builder) {
          return InfoBottomSheetWidget(title: title, message: message);
        });
  }

  void _getUserWallets() {
    String currentWalletId = _user!.currentWalletId;
    _wallet = _user!.walletList
        .singleWhere((element) => element.id == currentWalletId);
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _newWasteForm.spendDate,
      firstDate: DateTime(2000, 1),
      lastDate: DateTime(2040, 12),
      // builder: (BuildContext context, Widget child) {
      //   return Theme(
      //     data: Styles.calendarThemeData,
      //     child: child,
      //   );
      // },
    );
    if (picked != null) {
      setState(() {
        _newWasteForm.spendDate = picked;
      });
    }
  }

  _goBack(bool refresh) {
    Navigator.pop(context, refresh);
  }

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
                  'Novo gasto',
                  style: Styles.montTextTitle,
                ),
                Text(
                  _wallet.name,
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
              if (!loading) {
                _goBack(false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SizedBox(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: TextFormField(
                style: TextStyle(color: Colors.grey.shade100),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 50,
                controller: _newWasteForm.reason,
                validator: (value) {
                  if (value!.isEmpty) {
                    return Constants.getDefaultEmptyFieldMsg(context);
                  }

                  return null;
                },
                decoration: Styles.getTextFieldDecorationUnderline('Motivo'),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: TextFormField(
                style: TextStyle(color: Colors.grey.shade100),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 50,
                controller: _newWasteForm.waste,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyTextInputFormatter(symbol: '')],
                validator: (value) {
                  if (value!.isEmpty) {
                    return Constants.getDefaultEmptyFieldMsg(context);
                  }

                  if (Utils.convertStringFormToDouble(value) <= 0.0) {
                    return 'Quantia deve ser maior que zero';
                  }

                  return null;
                },
                decoration: Styles.getTextFieldDecorationUnderline('Quantia'),
              ),
            ),

            // calendar
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: InkWell(
                onTap: () {
                  _openDatePicker(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Data',
                      style: Styles.montTextGrey,
                    ),
                    Text(
                      DateFormat.yMd(Constants.ptLanguage)
                          .format(_newWasteForm.spendDate),
                      style: Styles.montText,
                    ),
                    Text(
                      'Data',
                      style: TextStyle(
                          color: Styles.mainBackgroundColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            // category
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: InkWell(
                onTap: () {
                  _openSpendingCategoryBottomSheet();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categoria',
                      style: Styles.montTextGrey,
                    ),
                    Text(
                      _categorySelected == null
                          ? Constants.EMPTY_STRING
                          : _categorySelected!.name,
                      style: Styles.montText,
                    ),
                    Text(
                      'Categoria',
                      style: TextStyle(
                          color: Styles.mainBackgroundColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            // btn
            Container(
              margin: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && !loading) {
                      _saveNewWaste();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Styles.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: Styles.defaultBorderRadius,
                    ),
                  ),
                  child: Text(
                    'Salvar',
                    style: Styles.buttonTextStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSpendingCategoryBottomSheet() async {
    String? selectedValue = await showModalBottomSheet(
        context: context,
        backgroundColor: Styles.cardColor,
        builder: (builder) {
          return CategoryBottomSheetWidget(
            _spendingCategoryList,
            _categorySelected!.value,
          );
        });

    if (selectedValue != null && selectedValue.isNotEmpty) {
      switchCategory(selectedValue);
    }
  }

  void switchCategory(String newValue) {
    var categorySelectedTemp = _spendingCategoryList
        .singleWhere((element) => element.value == newValue);

    setState(() {
      _categorySelected = categorySelectedTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildAppBar(),
                  _buildForm(),
                  const SizedBox(
                    width: double.infinity,
                    height: 80,
                  ),
                ],
              ),
            ),
            LoadingBlock(loading),
          ],
        ),
      ),
    );
  }
}

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meudin_app/models/forms/new_revenue_form.dart';
import 'package:meudin_app/models/user.dart';
import 'package:meudin_app/models/wallet.dart';
import 'package:meudin_app/pages/shared/info_bottom_sheet_widget.dart';
import 'package:meudin_app/pages/shared/loading_block.dart';
import 'package:meudin_app/services/transaction_service.dart';
import 'package:meudin_app/services/user_service.dart';
import 'package:meudin_app/utils/constants.dart';
import 'package:meudin_app/utils/styles.dart';
import 'package:meudin_app/utils/utils.dart';

class NewRevenueComponent extends StatefulWidget {
  @override
  _NewRevenueComponenState createState() => _NewRevenueComponenState();
}

class _NewRevenueComponenState extends State<NewRevenueComponent> {
  final _formKey = GlobalKey<FormState>();
  User? _user = UserService.currentUser;

  late TransactionService _transactionService;
  late NewRevenueForm _newRevenueForm;

  bool loading = false;
  late Wallet _wallet;

  _NewRevenueComponenState() {
    _transactionService = TransactionService();
    _newRevenueForm = NewRevenueForm();
  }

  @override
  void initState() {
    super.initState();
    _getUserWallets();
  }

  void _getUserWallets() {
    String currentWalletId = _user!.currentWalletId;
    _wallet = _user!.walletList
        .singleWhere((element) => element.id == currentWalletId);
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _newRevenueForm.payDay,
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
        _newRevenueForm.payDay = picked;
      });
    }
  }

  _saveNewRevenue() async {
    setState(() {
      loading = true;
    });

    FocusScope.of(context).unfocus();

    _newRevenueForm.walletId = _wallet.id;
    _newRevenueForm.uid = _user!.id;

    _transactionService.saveNewRevenue(_newRevenueForm).then((res) {
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
                  'Nova receita',
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
                controller: _newRevenueForm.reason,
                validator: (value) {
                  if (value!.isEmpty) {
                    return Constants.getDefaultEmptyFieldMsg();
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
                controller: _newRevenueForm.revenueValue,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyTextInputFormatter(symbol: '')],
                validator: (value) {
                  if (value!.isEmpty) {
                    return Constants.getDefaultEmptyFieldMsg();
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
                          .format(_newRevenueForm.payDay),
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
            //btn
            Container(
              margin: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && !loading) {
                      _saveNewRevenue();
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

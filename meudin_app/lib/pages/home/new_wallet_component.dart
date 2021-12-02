import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_app/pages/shared/info_bottom_sheet_widget.dart';
import 'package:meudin_app/pages/shared/loading_block.dart';
import 'package:meudin_app/services/user_service.dart';
import 'package:meudin_app/services/wallet_service.dart';
import 'package:meudin_app/utils/constants.dart';
import 'package:meudin_app/utils/styles.dart';

class NewWalletComponent extends StatefulWidget {
  @override
  _NewWalletComponentState createState() => _NewWalletComponentState();
}

class _NewWalletComponentState extends State<NewWalletComponent> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  TextEditingController walletNameController = TextEditingController();

  WalletService _walletService = WalletService();

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
          Text(
            'Nova carteira',
            style: Styles.montTextTitle,
          ),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.times,
              color: Styles.mainTextColor,
              size: 22,
            ),
            onPressed: () {
              if (!_loading) {
                _goBack(false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Form(
        key: _formKey,
        child: TextFormField(
          style: TextStyle(color: Colors.grey.shade100),
          controller: walletNameController,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value!.isEmpty) {
              return Constants.getDefaultEmptyFieldMsg(context);
            }

            return null;
          },
          decoration:
              Styles.getTextFieldDecorationUnderline('Nome da carteira'),
        ),
      ),
    );
  }

  _createNewWallet() {
    setState(() {
      _loading = true;
    });

    FocusScope.of(context).unfocus();

    String userId = UserService.currentUser!.id;
    String walletName = walletNameController.text;

    _walletService.createNewWallet(walletName, userId).then((res) {
      if (res.success) {
        UserService.currentUser!.currentWalletId = res.data;
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
        _loading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.mainBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(),
                _buildForm(),
              ],
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && !_loading) {
                      _createNewWallet();
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
            LoadingBlock(_loading),
          ],
        ),
      ),
    );
  }
}

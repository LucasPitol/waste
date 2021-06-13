import 'package:waste_app/pages/dialogs/confirm_dialog.dart';
import 'package:waste_app/pages/shared/loading_block.dart';
import 'package:waste_app/services/wallet_service.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/utils/styles.dart';
import 'package:flutter/material.dart';
import 'manage_wallets_app_bar.dart';

class EditWallet extends StatefulWidget {
  final String walletIdToEdit;
  EditWallet(this.walletIdToEdit);
  @override
  _EditWalletState createState() => _EditWalletState(walletIdToEdit);
}

class _EditWalletState extends State<EditWallet> {
  AuthService authService;
  var userDto = AuthService.currentUser;
  var languageCode = AuthService.currentUser.language;
  Wallet currentWallet;
  String walletIdToEdit;
  var _formKey;
  bool loading = false;
  TextEditingController walletNameController;
  String appBarTitle;
  bool isPtLanguage;

  WalletService walletService;

  _EditWalletState(String walletId) {
    this.isPtLanguage = userDto.language == Constants.languages[0];
    this.walletIdToEdit = walletId;
    this.authService = AuthService();
    this.walletService = WalletService();
    this._formKey = GlobalKey<FormState>();
    this.currentWallet = walletService.getWallet(walletId);
    this.walletNameController = TextEditingController();
    this.walletNameController.text = currentWallet.name;
    this.appBarTitle = this.languageCode == Constants.languages[0]
        ? 'Editar carteira'
        : 'Edit wallet';
  }

  void initState() {
    super.initState();
    this.authService.userExists(context);
  }

  Future<void> _updateWallet() async {
    setState(() {
      this.loading = true;
    });

    Wallet newWallet = currentWallet;

    newWallet.name = walletNameController.text;

    bool success = await this.walletService.updateWallet(newWallet);

    setState(() {
      this.loading = false;
    });

    if (success) {
      Navigator.pop(context, true);
    }
  }

  bool _isWalletNameRepeated(String input) {
    return this.walletService.isWalletNameRepeated(input);
  }

  Future<void> _deleteWallet() async {
    String title;

    String subtitle;

    bool deleteWallet = true;

    String uid = this.userDto.uid;

    List<Wallet> wallets = this.walletService.getUserWalletsLocal();

    if (wallets.length <= 1) {
      title = this.languageCode == Constants.languages[0]
          ? 'Não é possivel excluir sua unica carteira, quer reseta-la?'
          : 'You can\'t delete your unique wallet, would you like to restore?';

      subtitle = this.languageCode == Constants.languages[0]
          ? ('Todos os gastos de ' +
              currentWallet.name +
              ' carteira serão apagados')
          : ('All spends of this wallet will be deleted');

      deleteWallet = false;
    } else {
      title = this.languageCode == Constants.languages[0]
          ? ('Excluir ' + currentWallet.name + '?')
          : ('Delete ' + currentWallet.name + '?');

      subtitle = this.languageCode == Constants.languages[0]
          ? 'Todos os gastos relacionados a carteira tambem serão apagados'
          : 'All spends related to this wallet will be deleted';
    }

    bool delete = await _openConfirmDialog(title, subtitle);

    if (delete != null && delete) {
      setState(() {
        this.loading = true;
      });

      var success = deleteWallet
          ? await this.walletService.deleteWallet(walletIdToEdit, uid)
          : await this.walletService.deleteWalletTransactions(walletIdToEdit);

      if (success) {
        Navigator.pop(context, true);
      }
    }
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
      backgroundColor: Styles.mainBackgroundColor,
      appBar: ManageWalletsAppBar(context, this.appBarTitle),
      body: Stack(
        children: <Widget>[
          Container(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: _deleteWallet,
                        child: Text(
                          this.userDto.language == Constants.languages[0]
                              ? 'Excluir carteira'
                              : 'Delete wallet',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.0,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 20, bottom: 10, left: 20, right: 20),
                      child: TextFormField(
                        style: TextStyle(color: Colors.grey.shade100),
                        controller: walletNameController,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value.isEmpty) {
                            return Constants.getDefaultEmptyFieldMsg(
                                isPtLanguage);
                          }

                          if (_isWalletNameRepeated(value)) {
                            return this.languageCode == Constants.languages[0]
                                ? 'Já tem uma carteira com esse nome'
                                : 'You already have a wallet with this name';
                          }

                          return null;
                        },
                        decoration:
                            this.userDto.language == Constants.languages[0]
                                ? Styles.getTextFieldDecorationUnderline(
                                    'Nome da carteira')
                                : Styles.getTextFieldDecorationUnderline(
                                    'Wallet name'),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 40, left: 20, right: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: Styles.elevatedButtonStyle,
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _updateWallet();
                            }
                          },
                          child: Text(
                            this.languageCode == Constants.languages[0]
                                ? 'Salvar'
                                : 'Save',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          LoadingBlock(loading),
        ],
      ),
    );
  }
}

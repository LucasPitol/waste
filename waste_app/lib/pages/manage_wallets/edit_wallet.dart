import 'package:flutter/material.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/pages/dialogs/confirm_dialog.dart';
import 'package:waste_app/pages/shared/loading_block.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/wallet_service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

import 'manage_wallets_app_bar.dart';

class EditWallet extends StatefulWidget {
  String walletIdToEdit;
  EditWallet(this.walletIdToEdit);
  @override
  _EditWalletState createState() => _EditWalletState(walletIdToEdit);
}

class _EditWalletState extends State<EditWallet> {
  var userDto = AuthService.currentUser;
  Wallet currentWallet;
  String walletIdToEdit;
  var _formKey;
  bool loading = false;
  TextEditingController walletNameController;

  WalletService walletService;

  _EditWalletState(String walletId) {
    this.walletIdToEdit = walletId;
    this.walletService = WalletService();
    this._formKey = GlobalKey<FormState>();
    this.currentWallet = walletService.getWallet(walletId);
    this.walletNameController = TextEditingController();
    this.walletNameController.text = currentWallet.name;
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
      title = 'Não é possivel excluir sua unica carteira, quer reseta-la?';

      subtitle = 'Todos os gastos de ' +
          currentWallet.name +
          ' carteira serão apagados';

      deleteWallet = false;
    } else {
      title = 'Excluir ' + currentWallet.name + '?';

      subtitle =
          'Todos os gastos relacionados a carteira tambem serão apagados';
    }

    bool delete = await _openConfirmDialog(title, subtitle);

    if (delete != null && delete) {
      setState(() {
        this.loading = true;
      });

      var success = deleteWallet
          ? await this.walletService.deleteWallet(walletIdToEdit, uid)
          : await this.walletService.deleteWalletSpends(walletIdToEdit);

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
      appBar: ManageWalletsAppBar(context, 'Editar carteira'),
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
                      child: FlatButton(
                        onPressed: _deleteWallet,
                        child: Text(
                          this.userDto.language == Constants.languages[0]
                              ? 'Excluir carteira'
                              : 'Delete wallet',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
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
                        controller: walletNameController,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value.isEmpty) {
                            return Constants.getDefaultEmptyFieldMsg(
                                userDto.language);
                          }

                          if (_isWalletNameRepeated(value)) {
                            return 'Já tem uma carteira com esse nome';
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
                      child: ButtonTheme(
                        minWidth: double.infinity,
                        height: 50,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: Styles.defaultTextFieldBorderRadius,
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _updateWallet();
                            }
                          },
                          color: Colors.deepPurple,
                          child: Text(
                            'Salvar',
                            style: TextStyle(color: Colors.white, fontSize: 18),
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

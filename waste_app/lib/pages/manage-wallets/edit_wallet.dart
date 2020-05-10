import 'package:flutter/material.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/wallet-service.dart';
import 'package:waste_app/utils/constants.dart';
import 'package:waste_app/utils/styles.dart';

import 'manage-wallets-app-bar.dart';

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

  void _updateWallet() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ManageWalletsAppBar(context, 'Editar carteira'),
      body: Container(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topRight,
                  child: FlatButton(
                    onPressed: () {},
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
                  margin:
                      EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
                  child: TextFormField(
                    controller: walletNameController,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value) {
                      if (value.isEmpty) {
                        return Constants.getDefaultEmptyFieldMsg(
                            userDto.language);
                      }
                      return null;
                    },
                    decoration: this.userDto.language == Constants.languages[0]
                        ? Styles.getTextFieldDecorationUnderline(
                            'Nome da carteira')
                        : Styles.getTextFieldDecorationUnderline('Wallet name'),
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
    );
  }
}

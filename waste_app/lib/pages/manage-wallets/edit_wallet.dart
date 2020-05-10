import 'package:flutter/material.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/services/wallet-service.dart';

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

  WalletService walletService;

  _EditWalletState(String walletId) {
    this.walletIdToEdit = walletId;
    this.walletService = WalletService();
    this.currentWallet = walletService.getWallet(walletId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ManageWalletsAppBar(context, 'Editar carteira'),
      body: Container(
        child: Column(
          children: <Widget>[
            Text(currentWallet.name),
          ],
        ),
      ),
    );
  }
}

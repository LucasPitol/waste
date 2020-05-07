import 'package:flutter/material.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';

import 'manage-wallets-app-bar.dart';

class EditWallet extends StatelessWidget {
  var userDto = AuthService.currentUser;
  
  List<Wallet> wallets;
  
  EditWallet() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ManageWalletsAppBar(context, 'Editar carteira'),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              child: FlatButton(
                onPressed: () {},
                child: Text(
                  userDto.language == Constants.languages[0]
                      ? 'Criar nova carteira'
                      : 'Create new wallet',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

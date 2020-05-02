import 'package:flutter/material.dart';
import 'package:waste_app/models/wallet.dart';
import 'package:waste_app/services/auth_service.dart';
import 'package:waste_app/utils/constants.dart';

import 'manage-wallets-app-bar.dart';

class ManageWallets extends MaterialPageRoute<bool> {
  ManageWallets()
      : super(builder: (BuildContext context) {
          var userDto = AuthService.currentUser;
          List<Wallet> wallets;

          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              appBar: ManageWalletsAppBar(context),
              body: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topRight,
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
          });
        });
}

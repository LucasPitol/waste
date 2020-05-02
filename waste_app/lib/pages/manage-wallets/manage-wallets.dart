import 'package:flutter/material.dart';

import 'manage-wallets-app-bar.dart';

class ManageWallets extends MaterialPageRoute<bool> {
  ManageWallets()
      : super(builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              appBar: ManageWalletsAppBar(context),
              body: Text('data'),
            );
          });
        });
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_app/models/wallet.dart';
import 'package:meudin_app/utils/styles.dart';

class WalletsBottomSheetWidget extends StatefulWidget {
  final List<Wallet> walletList;

  WalletsBottomSheetWidget({required this.walletList});

  @override
  _WalletsBottomSheetWidgetState createState() =>
      _WalletsBottomSheetWidgetState(walletList);
}

class _WalletsBottomSheetWidgetState extends State<WalletsBottomSheetWidget> {
  final List<Wallet> walletList;

  _WalletsBottomSheetWidgetState(this.walletList);

  Widget _buildWalletItem(Wallet wallet) {
    int membersLength = wallet.membersId.length;
    String members = membersLength.toString();

    if (membersLength > 1) {
      members = members + ' membros';
    } else {
      members = members + ' membro';
    }

    return InkWell(
      onTap: () {
        _switchWallet(wallet.id);
      },
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          child: Column(
            children: [
              Text(
                wallet.name,
                style: Styles.montText,
              ),
              Text(
                members,
                style: Styles.montSubText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _switchWallet(String walletId) {
    Navigator.pop(context, walletId);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Icon(
              Icons.maximize,
              color: Colors.grey.shade800,
              size: 50,
            ),
          ),
          InkWell(
            onTap: () {
              print('new wallet');
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nova carteira',
                    style: Styles.textButtonTextStyle,
                  ),
                  FaIcon(
                    FontAwesomeIcons.plus,
                    color: Styles.primaryColor,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: double.infinity,
            height: 20,
          ),
          SizedBox(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: walletList.map((e) => _buildWalletItem(e)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

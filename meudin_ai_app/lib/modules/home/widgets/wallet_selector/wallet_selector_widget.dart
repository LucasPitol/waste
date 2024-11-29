import 'package:meudin_ai_app/modules/home/widgets/wallet_selector/wallet_selector_widget_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_ai_app/models/wallet.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletSelectorWidget extends StatelessWidget {
  final List<Wallet> walletList;

  const WalletSelectorWidget({super.key, required this.walletList});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletSelectorController>(
      init: WalletSelectorController(),
      builder: (controller) {
        return SizedBox(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: const Icon(
                  Icons.maximize,
                  color: Styles.grey,
                  size: 50,
                ),
              ),
              InkWell(
                onTap: () {
                  controller.handleNewWalletPage();
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      JoyText.secundaryText(
                        'Nova carteira',
                        fontWeight: FontWeight.bold,
                        textColor: Styles.primaryColor,
                      ),
                      const FaIcon(
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:
                        walletList.map((e) => _buildWalletItem(e, controller)).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletItem(Wallet wallet, WalletSelectorController controller) {
    int membersLength = wallet.membersIds.length;
    String members = membersLength.toString();

    if (membersLength > 1) {
      members = '$members membros';
    } else {
      members = '$members membro';
    }

    return InkWell(
      onTap: () {
        controller.switchWallet(wallet.id);
      },
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          child: Column(
            children: [
              JoyText(
                wallet.name,
              ),
              JoyText.secundaryText(
                members,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

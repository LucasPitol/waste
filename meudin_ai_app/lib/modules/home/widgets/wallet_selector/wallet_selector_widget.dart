import 'package:meudin_ai_app/modules/home/widgets/wallet_selector/wallet_selector_widget_controller.dart';
import 'package:meudin_ai_app/ui/app_icons.dart';
import 'package:meudin_ai_app/models/wallet.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/services/user_service.dart';

class WalletSelectorWidget extends StatelessWidget {
  final List<Wallet> walletList;
  final String? currentUserId;

  const WalletSelectorWidget({
    super.key, 
    required this.walletList,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<WalletSelectorController>(
      init: WalletSelectorController(),
      builder: (controller) {
        return Container(
          color: theme.brightness == Brightness.dark 
              ? theme.colorScheme.surface 
              : Styles.whiteColor,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Icon(Icons.maximize,
                  color: theme.brightness == Brightness.dark
                      ? theme.textTheme.bodyMedium?.color?.withOpacity(0.4) ?? Colors.grey
                      : Styles.grey,
                  size: 50,
                ),
              ),
              InkWell(
                onTap: () {
                  controller.handleNewWalletPage();
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      JoyText.secundaryText(
                        'Nova carteira',
                        fontWeight: FontWeight.bold,
                        size: 16,
                        textColor: Styles.primaryColor,
                      ),
                      const SizedBox(width: 16),
                      const AppIcon(
                        AppIcons.plus,
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
    final theme = Theme.of(Get.context!);
    int membersLength = wallet.membersIds.length;
    String members = membersLength.toString();
    final isOwner = currentUserId != null && wallet.ownerId == currentUserId;
    final isCurrentWallet = UserService.currentUser?.currentWalletId == wallet.id;

    if (membersLength > 1) {
      members = '$members membros';
    } else {
      members = '$members membro';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                controller.switchWallet(wallet.id);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isCurrentWallet 
                      ? (theme.brightness == Brightness.dark
                          ? Styles.primaryColor.withOpacity(0.15)
                          : Styles.primaryColor.withOpacity(0.1))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (isCurrentWallet)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: AppIcon(
                                    AppIcons.check,
                                    size: 14,
                                    color: Styles.primaryColor,
                                  ),
                                ),
                              Flexible(
                                child: JoyText(
                                  wallet.name,
                                ),
                              ),
                              if (isOwner)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Styles.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Dono',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Styles.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    JoyText.secundaryText(
                      size: 14,
                      members,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isOwner)
            IconButton(
              icon: AppIcon(
                AppIcons.ellipsisVertical,
                size: 16,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey,
              ),
              onPressed: () {
                controller.showWalletMenu(wallet);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

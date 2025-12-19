import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:meudin_ai_app/pages/new_wallet/new_wallet_page_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NewWalletPage extends StatelessWidget {
  const NewWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<NewWalletPageController>(
      init: NewWalletPageController(),
      builder: (controller) {
        // Show error bottom sheet if errorList is set
        if (controller.errorList != null && controller.errorList!.isNotEmpty) {
          Future.microtask(() {
            Get.bottomSheet(
              JoyModal.errorBottomSheet(
                context: context,
                errorList: controller.errorList!,
                title: 'Revise as informações preenchidas',
              ),
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              backgroundColor: Colors.transparent,
            );
            controller.errorList = null;
            controller.update();
          });
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.arrowLeft,
                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'Nova Carteira',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          backgroundColor: theme.brightness == Brightness.dark 
              ? theme.scaffoldBackgroundColor 
              : Styles.whiteConfortColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Wallet Name Field
                Container(
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark 
                        ? theme.colorScheme.surface 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.wallet,
                        size: 18,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: controller.walletNameController,
                          decoration: InputDecoration(
                            labelText: 'Nome da carteira',
                            border: InputBorder.none,
                            labelStyle: TextStyle(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey,
                            ),
                          ),
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color ?? Styles.primaryTextColor,
                          ),
                          textCapitalization: TextCapitalization.words,
                          maxLength: 50,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                JoyElevatedButton(
                  text: controller.loading ? 'Criando...' : 'Criar Carteira',
                  function: controller.loading ? null : controller.createWallet,
                  backgroundColor: Styles.primaryColor,
                  textColor: Styles.whiteColor,
                ),
                if (controller.loading)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Styles.primaryColor),
                          strokeWidth: 2.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

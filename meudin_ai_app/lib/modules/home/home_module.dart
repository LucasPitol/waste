import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_vision.dart';
import 'package:meudin_ai_app/modules/home/widgets/app_bar/home_app_bar.dart';
import 'package:meudin_ai_app/modules/home/home_module_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../ui/joy_ui.dart';

class HomeModule extends StatelessWidget {
  const HomeModule({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeModuleController>(
      init: HomeModuleController(),
      builder: (controller) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const HomeAppBar(),
              // plan
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: JoyText.h1(
                              controller.currentWallet.name,
                            ),
                          ),
                          IconButton(
                            icon: const FaIcon(
                              FontAwesomeIcons.sortDown,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              controller.openWalletSelector();
                            },
                          ),
                        ],
                      ),
                      JoyText.secundaryText('Plano iniciante'),
                      const SizedBox(
                        width: double.infinity,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
              WalletVisionWidget(
                startDate: controller.startDate,
                balance: controller.monthBalance,
                monthRevenue: controller.monthRevenue,
                monthSpends: controller.monthSpends,
                transactionDtoList: controller.transactionDtoList,
                twoFirstTransactionDtoList:
                    controller.twoFirstTransactionDtoList,
                loading: controller.loading,
              ),
            ],
          ),
        );
      },
    );
  }
}

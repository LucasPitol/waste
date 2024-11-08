import 'package:meudin_ai_app/modules/home/widgets/wallet_section/wallet_vision_controller.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletVisionWidget extends StatelessWidget {
  const WalletVisionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletVisionWidgetController>(
      init: WalletVisionWidgetController(),
      builder: (controller) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: controller.tabs.map(
              (element) {
                bool isOptionSelected = element.t1 == controller.selectedTab;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () {
                      controller.selectTab(element.t1);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: isOptionSelected
                          ? Styles.cardDecoration
                          : BoxDecoration(color: Styles.whiteConfortColor),
                      child: Text(
                        element.t2,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }
}

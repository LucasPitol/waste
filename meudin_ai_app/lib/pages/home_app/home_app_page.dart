import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meudin_ai_app/pages/home_app/home_app_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/ui/styles.dart';

class HomeAppPage extends StatelessWidget {
  const HomeAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeAppPageController>(
      init: HomeAppPageController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Styles.whiteConfortColor,
          body: SafeArea(
            child: Container(),
          ),
          floatingActionButton: SpeedDial(
            backgroundColor: Styles.whiteColor,
            icon: FontAwesomeIcons.plus,
            foregroundColor: Styles.primaryColor,
            overlayColor: Styles.whiteColor,
            activeIcon: FontAwesomeIcons.xmark,
            children: [
              SpeedDialChild(
                backgroundColor: Styles.whiteConfortColor,
                child: const FaIcon(
                  FontAwesomeIcons.arrowTrendDown,
                  color: Colors.red,
                ),
              ),
              SpeedDialChild(
                backgroundColor: Styles.whiteConfortColor,
                child: const FaIcon(
                  FontAwesomeIcons.arrowTrendUp,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

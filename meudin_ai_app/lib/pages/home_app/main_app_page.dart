import 'package:meudin_ai_app/modules/home/home_module_controller.dart';
import 'package:meudin_ai_app/pages/home_app/main_app_page_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainAppPage extends StatelessWidget {
  const MainAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GetBuilder<MainAppPageController>(
      init: MainAppPageController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: controller.widgetOptions[controller.selectedIndex],
          ),
          floatingActionButton: SpeedDial(
            backgroundColor: theme.brightness == Brightness.dark 
                ? theme.colorScheme.surface 
                : Styles.whiteColor,
            icon: FontAwesomeIcons.plus,
            foregroundColor: Styles.primaryColor,
            overlayColor: theme.brightness == Brightness.dark 
                ? theme.colorScheme.surface 
                : Styles.whiteColor,
            activeIcon: FontAwesomeIcons.xmark,
            children: [
              SpeedDialChild(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  child: const FaIcon(
                    FontAwesomeIcons.arrowTrendDown,
                    color: Colors.red,
                  ),
                  onTap: () async {
                    final result = await Get.toNamed(AppRoutes.newSpendRoute);
                    if (result != null && result == true) {
                      final homeController = Get.find<HomeModuleController>();
                      homeController.updatePageData();
                    }
                  }),
              SpeedDialChild(
                backgroundColor: theme.scaffoldBackgroundColor,
                child: const FaIcon(
                  FontAwesomeIcons.arrowTrendUp,
                  color: Colors.green,
                ),
                onTap: () async {
                  // Navigate to New Revenue Page and wait for result
                  final result = await Get.toNamed(AppRoutes.newRevenueRoute);
                  if (result != null && result == true) {
                    final homeController = Get.find<HomeModuleController>();
                    homeController.updatePageData();
                  }
                },
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            color: theme.brightness == Brightness.dark 
                ? theme.colorScheme.surface 
                : Styles.whiteColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    controller.onItemTapped(0);
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.house,
                    color: controller.selectedIndex == 0
                        ? Styles.primaryColor
                        : Styles.grey,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                IconButton(
                  onPressed: () {
                    controller.onItemTapped(1);
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.chartPie,
                    color: controller.selectedIndex == 1
                        ? Styles.primaryColor
                        : Styles.grey,
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

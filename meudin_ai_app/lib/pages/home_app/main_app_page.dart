import 'package:meudin_ai_app/modules/home/home_module_controller.dart';
import 'package:meudin_ai_app/modules/insights/insights_module_controller.dart';
import 'package:meudin_ai_app/pages/home_app/main_app_page_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/ui/joy_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainAppPage extends StatelessWidget {
  const MainAppPage({super.key});

  /// Atualiza os dados da tela ativa após criar uma nova transação
  static void _refreshCurrentPage(int selectedIndex) {
    // Atualiza a tela ativa
    if (selectedIndex == 0) {
      // Tela Home
      if (Get.isRegistered<HomeModuleController>()) {
        final homeController = Get.find<HomeModuleController>();
        homeController.updatePageData();
      }
    } else if (selectedIndex == 1) {
      // Tela Insights
      if (Get.isRegistered<InsightsModuleController>()) {
        final insightsController = Get.find<InsightsModuleController>();
        insightsController.refreshAll();
      }
    }
    
    // Também tenta atualizar a outra tela se o controller estiver disponível
    // Isso garante que quando o usuário trocar de tela, os dados estejam atualizados
    if (selectedIndex == 0) {
      if (Get.isRegistered<InsightsModuleController>()) {
        final insightsController = Get.find<InsightsModuleController>();
        insightsController.refreshAll();
      }
    } else {
      if (Get.isRegistered<HomeModuleController>()) {
        final homeController = Get.find<HomeModuleController>();
        homeController.updatePageData();
      }
    }
  }

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
          floatingActionButton: theme.brightness == Brightness.dark
              ? Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 0.5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SpeedDial(
                    backgroundColor: theme.colorScheme.surface,
                    icon: FontAwesomeIcons.plus,
                    foregroundColor: Styles.primaryColor,
                    overlayColor: theme.colorScheme.surface,
                    activeIcon: FontAwesomeIcons.xmark,
                    elevation: 8,
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
                            _refreshCurrentPage(controller.selectedIndex);
                          }
                        },
                      ),
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
                            _refreshCurrentPage(controller.selectedIndex);
                          }
                        },
                      ),
                    ],
                  ),
                )
              : SpeedDial(
              backgroundColor: Styles.whiteColor,
              icon: FontAwesomeIcons.plus,
              foregroundColor: Styles.primaryColor,
              overlayColor: Styles.whiteColor,
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
                      _refreshCurrentPage(controller.selectedIndex);
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
                    _refreshCurrentPage(controller.selectedIndex);
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

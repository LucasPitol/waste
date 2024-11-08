import 'package:meudin_ai_app/modules/overview/overview_module.dart';
import 'package:meudin_ai_app/modules/home/home_module.dart';
import 'package:get/get.dart';

class MainAppPageController extends GetxController {
  int selectedIndex = 0;
  final widgetOptions = [
    const HomeModule(),
    const OverviewModule(),
  ];

  onItemTapped(int index) {
    selectedIndex = index;
    update();
  }
}

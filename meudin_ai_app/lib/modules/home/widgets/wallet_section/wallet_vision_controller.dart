import 'package:meudin_ai_app/models/tuple.dart';
import 'package:get/get.dart';

class WalletVisionWidgetController extends GetxController {
  late List<Tuple> tabs;
  late int selectedTab;
  late bool loading;

  WalletVisionWidgetController() {
    tabs = [
      Tuple(t1: 0, t2: 'Visão'),
      Tuple(t1: 1, t2: 'Membros'),
    ];
    selectedTab = 0;
    loading = true;
  }

  selectTab(int newValue) {
    selectedTab = newValue;
    update();
  }
}

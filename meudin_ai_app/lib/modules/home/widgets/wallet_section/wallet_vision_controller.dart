import 'package:meudin_ai_app/models/transaction.dart';
import 'package:meudin_ai_app/models/tuple.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/modules/home/home_module_controller.dart';

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

  goToSeeAllTransactionsPage({
    required List<Transaction> transactions,
    required DateTime startDate,
  }) async {
    final refresh = await Get.toNamed(
      AppRoutes.transactionsListRoute,
      arguments: [transactions, startDate],
    );

    if (refresh != null && refresh) {
      // Refresh data in home module
      final homeController = Get.find<HomeModuleController>();
      await homeController.updatePageData();
    }
  }
}

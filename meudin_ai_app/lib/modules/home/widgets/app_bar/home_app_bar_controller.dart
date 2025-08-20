import 'package:meudin_ai_app/modules/home/home_module_controller.dart';
import 'package:get/get.dart';

class HomeAppBarController extends GetxController {
  refreshPage() async {
    final HomeModuleController homeModuleController =
        Get.find<HomeModuleController>();

    homeModuleController.refreshAll();
  }
}

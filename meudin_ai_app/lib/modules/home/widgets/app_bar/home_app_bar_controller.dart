import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:get/get.dart';

class HomeAppBarController extends GetxController {
  goToProfile() {
    Get.toNamed(AppRoutes.profileRoute);
  }
}

import 'package:meudin_ai_app/pages/home_app/main_app_page.dart';
import 'package:get/get.dart';

class AppRoutes {
  static String homeAppRoute = '/home-app';

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(
      name: homeAppRoute,
      page: () => const MainAppPage(),
    ),
  ];
}

import 'package:meudin_ai_app/pages/transaction/transactions_page.dart';
import 'package:meudin_ai_app/pages/home_app/main_app_page.dart';
import 'package:meudin_ai_app/pages/sign_in/sign_in_page.dart';
import 'package:get/get.dart';

class AppRoutes {
  static String homeAppRoute = '/home-app';
  static String transactionsListRoute = '/transactions';
  static String signInRoute = '/sign-in';
  static String profileRoute = '/profile';

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(
      name: homeAppRoute,
      page: () => const MainAppPage(),
    ),
    GetPage(
      name: transactionsListRoute,
      page: () => const TransactionsPage(),
    ),
    GetPage(
      name: signInRoute,
      page: () => const SignInPage(),
    ),
    // GetPage(
    //   name: profileRoute,
    //   page: () => const ProfilePage(),
    // ),
  ];
}

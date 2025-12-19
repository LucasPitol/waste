import 'package:meudin_ai_app/pages/new_revenue/new_revenue_page.dart';
import 'package:meudin_ai_app/pages/splash/splash_page.dart';
import 'package:meudin_ai_app/pages/new_spend/new_spend_page.dart';
import 'package:meudin_ai_app/pages/recover_password/recover_password_page.dart';
import 'package:meudin_ai_app/pages/transaction/transactions_page.dart';
import 'package:meudin_ai_app/pages/home_app/main_app_page.dart';
import 'package:meudin_ai_app/pages/sign_in/sign_in_page.dart';
import 'package:meudin_ai_app/pages/sign_up/sign_up_page.dart';
import 'package:meudin_ai_app/pages/profile/profile_page.dart';
import 'package:meudin_ai_app/pages/faq/faq_page.dart';
import 'package:meudin_ai_app/pages/new_wallet/new_wallet_page.dart';
import 'package:meudin_ai_app/pages/edit_spend/edit_spend_page.dart';
import 'package:meudin_ai_app/pages/edit_revenue/edit_revenue_page.dart';
import 'package:get/get.dart';

class AppRoutes {
  static String splashRoute = '/';
  static String homeAppRoute = '/home-app';
  static String transactionsListRoute = '/transactions';
  static String signInRoute = '/sign-in';
  static String signUpRoute = '/sign-up';
  static String recoverPasswordRoute = '/recover-password';
  static String profileRoute = '/profile';
  static String faqRoute = '/faq';
  static String newRevenueRoute = '/new-revenue';
  static String newSpendRoute = '/new-spend';
  static String newWalletRoute = '/new-wallet';
  static String editSpendRoute = '/edit-spend';
  static String editRevenueRoute = '/edit-revenue';

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage(
      name: splashRoute,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: homeAppRoute,
      page: () => const MainAppPage(),
    ),
    GetPage(
      name: transactionsListRoute,
      page: () => const TransactionsPage(),
    ),
    GetPage(
      name: newRevenueRoute,
      page: () => const NewRevenuePage(),
    ),
    GetPage(
      name: newSpendRoute,
      page: () => const NewSpendPage(),
    ),
    GetPage(
      name: signInRoute,
      page: () => const SignInPage(),
    ),
    GetPage(
      name: signUpRoute,
      page: () => const SignUpPage(),
    ),
    GetPage(
      name: recoverPasswordRoute,
      page: () => const RecoverPasswordPage(),
    ),
    GetPage(
      name: profileRoute,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: faqRoute,
      page: () => const FAQPage(),
    ),
    GetPage(
      name: newWalletRoute,
      page: () => const NewWalletPage(),
    ),
    GetPage(
      name: editSpendRoute,
      page: () => const EditSpendPage(),
    ),
    GetPage(
      name: editRevenueRoute,
      page: () => const EditRevenuePage(),
    ),
  ];
}

import 'package:intl/date_symbol_data_local.dart';
import 'package:meudin_ai_app/routes/app_routes.dart';
import 'package:meudin_ai_app/ui/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meudin_ai_app/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(Constants.ptLanguageCode, null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Styles.mainTheme,
      initialRoute: AppRoutes.splashRoute,
      getPages: AppRoutes.pages,
    );
  }
}
